import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:touring_game/firebase_options.dart';

import 'auth_user.dart';
import 'auth_exceptions.dart';
import 'auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> deleteUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String uid = user.uid;
        FirebaseAuth.instance.currentUser!.uid;
        await user.delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('activities_done')
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          await logOut();
          throw RequiresRecentLoginAuthException();
        }
      }
    } else {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw InvalidLoginCredentialsAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidLoginCredentialsAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVeryfication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> sendPasswordReset(
      {required String toEmail, required bool? loggedIn}) async {
    try {
      if (loggedIn != null) {
        if (loggedIn) {
          toEmail = FirebaseAuth.instance.currentUser!.email!;
        }
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'user-not-found':
          throw UserNotFoundException();
        case 'firebase_auth/user-not-found':
        default:
          throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }
}
