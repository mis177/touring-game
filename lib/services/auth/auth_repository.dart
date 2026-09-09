import 'package:touring_game/services/auth/auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> watchAuthState();
  Future<AuthUser> logIn({required String email, required String password});

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();

  Future<void> initialize();

  Future<AuthUser?> refreshCurrentUser();

  Future<void> sendPasswordReset(String email);

  Future<void> sendPasswordResetForCurrentUser();

  Future<void> deleteUser();
}
