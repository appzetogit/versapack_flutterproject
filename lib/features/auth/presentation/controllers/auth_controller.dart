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

      // A stored token proves nothing on its own: the backend evicts a session
      // when the account signs in elsewhere, and it answers 401 for a token
      // whose tokenVersion has moved on. Asking the server is the only way to
      // know the session is still live.
      final payload = await _api.me();
      final seller = SellerModel.fromJson(payload);

      await storage.saveSeller(
        id: seller.id,
        status: seller.status,
        phone: seller.phone,
      );

      state = _stateForSeller(seller);
      startupLog('auth.resolveSession done', state.runtimeType);
    } on DioException catch (e) {
      // 401 means the session is genuinely gone -- expired, or evicted by a
      // sign-in on another device -- so the stored tokens are dead weight and
      // are cleared. Any other failure (no signal, server down, timeout) is
      // transient: the tokens are kept so a retry can still succeed, and the
      // seller merely lands on the login screen rather than being wiped.
      final status = e.response?.statusCode;
      if (status == 401) {
        await ref.read(tokenStorageProvider).clear();
        final message = e.error is ApiException
            ? (e.error as ApiException).message
            : null;
        state = AuthLoggedOut(reason: message);
      } else {
        state = const AuthLoggedOut();
      }
      startupLog('auth.resolveSession rejected', status);
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

  /// Re-reads the seller from the server and moves to whatever state they are
  /// now in.
  ///
  /// Used by the screens that finish registration: a store that has just
  /// submitted its papers is normally `pending`, so this is what routes it to
  /// the waiting screen rather than the dashboard. It replaces a mock sign-in
  /// that granted a fake approved session to anyone who pressed Continue.
  Future<void> refreshSession() async {
    try {
      final seller = SellerModel.fromJson(await _api.me());
      await ref
          .read(tokenStorageProvider)
          .saveSeller(
            id: seller.id,
            status: seller.status,
            phone: seller.phone,
          );
      state = _stateForSeller(seller);
    } on DioException catch (e) {
      final message = e.error is ApiException
          ? (e.error as ApiException).message
          : '';
      final lower = message.toLowerCase();
      // Approval state arrives as a login failure, not a field.
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
