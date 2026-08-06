import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/core/logging/startup_log.dart';
import 'package:quick_commerce_seller/core/network/api_exception.dart';
import 'package:quick_commerce_seller/core/network/dio_client.dart';
import 'package:quick_commerce_seller/core/providers/core_providers.dart';
import 'package:quick_commerce_seller/core/providers/session_reset.dart';
import 'package:quick_commerce_seller/features/auth/data/auth_api.dart';
import 'package:quick_commerce_seller/features/auth/domain/seller_model.dart';
import 'package:quick_commerce_seller/features/auth/presentation/controllers/auth_state.dart';

/// Owns the session. A synchronous state machine rather than an `AsyncNotifier`
/// because the router redirect has to read the current state on every
/// navigation without unwrapping an `AsyncValue`.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final session = ref.watch(authSessionProvider);

    // A forced logout can originate deep inside the Dio interceptor, with no
    // widget in the call stack. This is how it reaches the router.
    void onSessionEvent() {
      if (session.isExpired && state is! AuthLoggedOut) {
        state = AuthLoggedOut(reason: session.reason);
      }
    }

    session.addListener(onSessionEvent);
    ref.onDispose(() => session.removeListener(onSessionEvent));

    return const AuthInitial();
  }

  AuthApi get _api => ref.read(authApiProvider);

  /// Resolves the stored session against the server. Called once from the
  /// splash screen — a stored token proves nothing on its own, since the
  /// backend evicts sessions when the account signs in elsewhere.
  Future<void> resolveSession() async {
    startupLog('auth.resolveSession start');
    try {
      final storage = ref.read(tokenStorageProvider);
      final hasSession = await storage.hasSession.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );

      if (!hasSession) {
        state = const AuthLoggedOut();
        startupLog('auth.resolveSession done', 'AuthLoggedOut (no token)');
        return;
      }

      // Mock session handling while backend is disconnected
      const mockSeller = SellerModel(
        id: 'seller-mock-1',
        name: 'Store Partner',
        storeName: 'Fresh Mart Superstore',
        phone: '9876543210',
        email: 'seller@freshmart.com',
        status: 'approved',
        imageUrl: '',
        isAcceptingOrders: true,
        rating: 4.8,
        totalRatings: 124,
      );
      state = const AuthAuthenticated(seller: mockSeller);
      startupLog('auth.resolveSession done', state.runtimeType);
    } catch (e) {
      state = const AuthLoggedOut();
      startupLog('auth.resolveSession FAILED', e);
    }
  }

  /// Last-resort escape from [AuthInitial]. Used by the splash watchdog when
  /// [resolveSession] has neither completed nor thrown — which can only happen
  /// if a platform channel never answers at all.
  void forceLoggedOut({String? reason}) {
    if (state is! AuthInitial) return;
    state = AuthLoggedOut(reason: reason);
    startupLog('auth.forceLoggedOut', reason);
  }

  /// Mock sign-in for Phase 1 UI presentation.
  /// Bypasses backend API calls and directly sets [AuthAuthenticated] state so
  /// the app routes directly to [/home]. When Phase 2 backend integration is
  /// ready, swap this back to [requestOtp]/[verifyOtp].
  void loginMock({String phone = '9876543210'}) {
    const mockSeller = SellerModel(
      id: 'seller-mock-1',
      name: 'Store Partner',
      storeName: 'Fresh Mart Superstore',
      phone: '9876543210',
      email: 'seller@freshmart.com',
      status: 'approved',
      imageUrl: '',
      isAcceptingOrders: true,
      rating: 4.8,
      totalRatings: 124,
    );
    ref
        .read(tokenStorageProvider)
        .saveTokens(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
        );
    state = const AuthAuthenticated(seller: mockSeller);
  }

  Future<void> requestOtp(String phone) async {
    final payload = await _api.requestOtp(phone);
    state = AuthOtpSent(phone: phone, debugOtp: payload['otp']?.toString());
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    try {
      final payload = await _api.verifyOtp(phone: phone, otp: otp);

      if (payload['needsRegistration'] == true) {
        state = AuthNeedsRegistration(phone: phone);
        return;
      }

      final accessToken = (payload['accessToken'] ?? '').toString();
      final refreshToken = (payload['refreshToken'] ?? '').toString();
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw const ApiException(
          message: 'Sign-in did not return a valid session. Please try again.',
        );
      }

      final storage = ref.read(tokenStorageProvider);
      await storage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final user = payload['user'];
      final seller = SellerModel.fromJson(
        user is Map ? Map<String, dynamic>.from(user) : const {},
      );
      await storage.saveSeller(
        id: seller.id,
        status: seller.status,
        phone: seller.phone.isNotEmpty ? seller.phone : phone,
      );

      ref.read(authSessionProvider).reset();
      // A previous seller's data must not survive into this session.
      resetSessionScopedProviders(ref);
      state = _stateForSeller(seller);
    } on DioException catch (e) {
      // The backend reports approval state as a login failure rather than a
      // field, so these two messages are the only way to reach those screens.
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : '';
      final lower = message.toLowerCase();
      if (lower.contains('pending approval')) {
        state = AuthPendingApproval(message: message);
        return;
      }
      if (lower.contains('rejected')) {
        state = AuthRejected(message: message);
        return;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    final refreshToken = await storage.refreshToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _api.logout(refreshToken: refreshToken);
      } on DioException {
        // A server-side de-registration failure must not strand the seller in a
        // session they asked to leave. Local teardown proceeds regardless.
      }
    }

    await storage.clear();
    ref.read(authSessionProvider).reset();
    resetSessionScopedProviders(ref);
    state = const AuthLoggedOut();
  }

  /// Returns to the phone-entry step from the OTP screen.
  void cancelOtp() => state = const AuthLoggedOut();

  AuthState _stateForSeller(SellerModel seller) {
    if (seller.isRejected) {
      return AuthRejected(
        message:
            'Your registration was rejected. Please contact support for help.',
      );
    }
    // A `pending` seller that the backend let through is under re-review after
    // a profile edit — they keep full access, so only a never-approved store
    // lands on the waiting screen. The backend enforces which is which by
    // refusing the login outright.
    return AuthAuthenticated(seller: seller);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
