import '../model/user.dart';

/// Result of requesting an OTP. In non-production the backend echoes the code
/// back, which the OTP screen shows as a hint instead of making testers guess.
class OtpRequestResult {
  const OtpRequestResult({required this.phone, this.debugOtp});

  final String phone;
  final String? debugOtp;
}

class AuthSession {
  const AuthSession({required this.user, required this.isNewUser});

  final User user;
  final bool isNewUser;
}

abstract interface class AuthRepository {
  Future<OtpRequestResult> requestOtp(String phone);

  Future<AuthSession> verifyOtp({
    required String phone,
    required String otp,
    String? name,
  });

  /// Cached user from a previous session, if the device still holds a token.
  User? get cachedUser;

  bool get isSignedIn;

  Future<User> currentUser();

  Future<User> updateProfile({
    String? name,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
  });

  Future<Wallet> wallet();

  Future<void> signOut();

  Future<void> deleteAccount();
}
