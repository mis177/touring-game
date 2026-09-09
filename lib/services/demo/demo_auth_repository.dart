import 'package:touring_game/services/auth/auth_repository.dart';
import 'package:touring_game/services/auth/auth_user.dart';

class DemoAuthRepository implements AuthRepository {
  AuthUser? _user = demoUser;

  static const demoUser = AuthUser(
    id: 'demo-user',
    email: 'demo@visiter.app',
    isEmailVerified: true,
  );

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> watchAuthState() => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<AuthUser?> refreshCurrentUser() async => _user;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async => _user = demoUser;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async => _user = demoUser;

  @override
  Future<void> logOut() async => _user = null;

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> sendPasswordResetForCurrentUser() async {}

  @override
  Future<void> deleteUser() async => _user = null;
}
