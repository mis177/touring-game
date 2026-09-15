import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/auth_repository.dart';
import 'package:touring_game/services/auth/auth_user.dart';
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  AuthServiceUser? get _serviceUser {
    try {
      return _authService.currentUser;
    } on FirebaseServiceException catch (error) {
      throw GenericAuthException(error.cause);
    }
  }

  @override
  Future<void> initialize() async {
    try {
      await _authService.initialize();
    } on FirebaseServiceException catch (error) {
      throw GenericAuthException(error.cause);
    }
  }

  @override
  Future<AuthUser?> refreshCurrentUser() async {
    try {
      await _authService.reloadCurrentUser();
      return currentUser;
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  @override
  AuthUser? get currentUser {
    return _mapUser(_serviceUser);
  }

  @override
  Stream<AuthUser?> watchAuthState() async* {
    try {
      await for (final user in _authService.watchAuthState()) {
        yield _mapUser(user);
      }
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  AuthUser? _mapUser(AuthServiceUser? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      id: user.id,
      email: user.email,
      isEmailVerified: user.isEmailVerified,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.createUser(email: email, password: password);
      return currentUser ?? (throw const UserNotLoggedInAuthException());
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.logIn(email: email, password: password);
      return currentUser ?? (throw const UserNotLoggedInAuthException());
    } on FirebaseServiceException catch (error) {
      final mappedError = _mapAuthError(error);
      throw mappedError is UserNotFoundException
          ? const InvalidLoginCredentialsAuthException()
          : mappedError;
    }
  }

  @override
  Future<void> logOut() async {
    if (_serviceUser == null) {
      throw const UserNotLoggedInAuthException();
    }
    try {
      await _authService.logOut();
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_serviceUser == null) {
      throw const UserNotLoggedInAuthException();
    }
    try {
      await _authService.sendEmailVerification();
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty) {
      throw const InvalidEmailAuthException();
    }
    try {
      await _authService.sendPasswordReset(email);
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  @override
  Future<void> sendPasswordResetForCurrentUser() async {
    final email = _serviceUser?.email;
    if (email == null) {
      throw const UserNotLoggedInAuthException();
    }
    await sendPasswordReset(email);
  }

  @override
  Future<void> deleteUser() async {
    final user = _serviceUser;
    if (user == null) {
      throw const UserNotLoggedInAuthException();
    }
    final lastSignIn = user.lastSignInTime;
    if (lastSignIn == null ||
        DateTime.now().difference(lastSignIn) > const Duration(minutes: 4)) {
      throw const RequiresRecentLoginAuthException();
    }

    try {
      // Successful Auth deletion triggers the configured privileged backend
      // cleanup. User data must not be removed while the account is active.
      await _authService.deleteCurrentUser();
    } on FirebaseServiceException catch (error) {
      throw _mapAuthError(error);
    }
  }

  AuthenticationException _mapAuthError(FirebaseServiceException error) {
    switch (error.code) {
      case 'weak-password':
        return const WeakPasswordAuthException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseAuthException();
      case 'invalid-email':
        return const InvalidEmailAuthException();
      case 'user-not-found':
        return const UserNotFoundException();
      case 'invalid-credential':
      case 'wrong-password':
        return const InvalidLoginCredentialsAuthException();
      case 'requires-recent-login':
        return const RequiresRecentLoginAuthException();
      default:
        return GenericAuthException(error.cause);
    }
  }
}
