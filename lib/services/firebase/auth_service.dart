import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:touring_game/firebase_options.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';

class AuthServiceUser {
  const AuthServiceUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    required this.lastSignInTime,
  });

  final String id;
  final String email;
  final bool isEmailVerified;
  final DateTime? lastSignInTime;
}

abstract interface class AuthService {
  AuthServiceUser? get currentUser;
  Stream<AuthServiceUser?> watchAuthState();

  Future<void> initialize();
  Future<void> reloadCurrentUser();
  Future<void> createUser({required String email, required String password});
  Future<void> logIn({required String email, required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset(String email);
  Future<void> deleteCurrentUser();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _authOverride = auth;

  final FirebaseAuth? _authOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  @override
  AuthServiceUser? get currentUser {
    try {
      return _mapUser(_auth.currentUser);
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  @override
  Stream<AuthServiceUser?> watchAuthState() async* {
    try {
      await for (final user in _auth.userChanges()) {
        yield _mapUser(user);
      }
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  @override
  Future<void> initialize() => _guard(
    () =>
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  );

  @override
  Future<void> reloadCurrentUser() => _guard(() async {
    await _auth.currentUser?.reload();
  });

  @override
  Future<void> createUser({required String email, required String password}) =>
      _guard(
        () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

  @override
  Future<void> logIn({required String email, required String password}) =>
      _guard(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> logOut() => _guard(_auth.signOut);

  @override
  Future<void> sendEmailVerification() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const FirebaseServiceException(
        code: 'user-not-found',
        cause: 'No authenticated Firebase user.',
      );
    }
    await user.sendEmailVerification();
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> deleteCurrentUser() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const FirebaseServiceException(
        code: 'user-not-found',
        cause: 'No authenticated Firebase user.',
      );
    }
    await user.delete();
  });

  Future<void> _guard<T>(Future<T> Function() operation) async {
    try {
      await operation();
    } on FirebaseServiceException {
      rethrow;
    } on FirebaseException catch (error) {
      throw FirebaseServiceException(code: error.code, cause: error);
    } catch (error) {
      throw FirebaseServiceException(cause: error);
    }
  }

  AuthServiceUser? _mapUser(User? user) {
    final email = user?.email;
    if (user == null || email == null) {
      return null;
    }
    return AuthServiceUser(
      id: user.uid,
      email: email,
      isEmailVerified: user.emailVerified,
      lastSignInTime: user.metadata.lastSignInTime,
    );
  }
}
