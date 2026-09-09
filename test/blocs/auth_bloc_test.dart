import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/auth_repository.dart';
import 'package:touring_game/services/auth/auth_user.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';

void main() {
  const verifiedUser = AuthUser(
    id: 'user-1',
    email: 'user@example.com',
    isEmailVerified: true,
  );
  const unverifiedUser = AuthUser(
    id: 'user-1',
    email: 'user@example.com',
    isEmailVerified: false,
  );

  test('initialization failure is represented as a login state', () async {
    final failure = Exception('initialization failed');
    final bloc = AuthBloc(_FakeAuthRepository(initializeError: failure));

    bloc.add(const AuthEventInitialize());
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateLoggingIn && state.exception != null,
    );

    expect(state.exception, same(failure));
    await bloc.close();
  });

  test('verified login opens the authenticated state', () async {
    final repository = _FakeAuthRepository(loginUser: verifiedUser);
    final bloc = AuthBloc(repository);

    bloc.add(const AuthEventLogIn(' user@example.com ', 'password'));
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateLoggedIn && !state.isLoading,
    );

    expect(state.userEmail, verifiedUser.email);
    expect(repository.lastLoginEmail, verifiedUser.email);
    await bloc.close();
  });

  test('unverified login does not automatically resend verification', () async {
    final repository = _FakeAuthRepository(loginUser: unverifiedUser);
    final bloc = AuthBloc(repository);

    bloc.add(const AuthEventLogIn('user@example.com', 'password'));
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateNeedsVerification && !state.isLoading,
    );

    expect(state.exception, isNull);
    expect(repository.verificationSendCount, 0);
    await bloc.close();
  });

  test(
    'verification failure after registration keeps the authenticated session',
    () async {
      final failure = Exception('send failed');
      final repository = _FakeAuthRepository(
        registrationUser: unverifiedUser,
        verificationError: failure,
      );
      final bloc = AuthBloc(repository);

      bloc.add(const AuthEventRegister('user@example.com', 'password'));
      final state = await bloc.stream.firstWhere(
        (state) =>
            state is AuthStateNeedsVerification && state.exception != null,
      );

      expect(state.userEmail, unverifiedUser.email);
      expect(state.exception, same(failure));
      expect(repository.currentUser, unverifiedUser);
      await bloc.close();
    },
  );

  test('verification resend failure stays on verification screen', () async {
    final failure = Exception('send failed');
    final bloc = AuthBloc(
      _FakeAuthRepository(
        initialUser: unverifiedUser,
        verificationError: failure,
      ),
    );

    bloc.add(const AuthEventSendEmailVerification());
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateNeedsVerification && state.exception != null,
    );

    expect(state.exception, same(failure));
    await bloc.close();
  });

  test('refreshing a verified Firebase user opens the app', () async {
    final repository = _FakeAuthRepository(
      initialUser: unverifiedUser,
      refreshedUser: verifiedUser,
    );
    final bloc = AuthBloc(repository);

    bloc.add(const AuthEventRefreshUser());
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateLoggedIn && !state.isLoading,
    );

    expect(state.userEmail, verifiedUser.email);
    await bloc.close();
  });

  test('unknown reset email does not disclose account existence', () async {
    final repository = _FakeAuthRepository(
      passwordResetError: const UserNotFoundException(),
    );
    final bloc = AuthBloc(repository);

    bloc.add(const AuthEventPasswordResetRequested('missing@example.com'));
    final state = await bloc.stream.firstWhere(
      (state) =>
          state is AuthStateForgotPassword &&
          state.feedback == AuthFeedback.passwordResetEmailSent,
    );

    expect(state.exception, isNull);
    await bloc.close();
  });

  test('failed logout preserves the authenticated screen', () async {
    final failure = Exception('logout failed');
    final bloc = AuthBloc(
      _FakeAuthRepository(initialUser: verifiedUser, logoutError: failure),
    );

    bloc.add(const AuthEventLogOut());
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateLoggedIn && state.exception != null,
    );

    expect(state.userEmail, verifiedUser.email);
    expect(state.exception, same(failure));
    await bloc.close();
  });

  test('failed account deletion preserves the authenticated screen', () async {
    final failure = Exception('delete failed');
    final bloc = AuthBloc(
      _FakeAuthRepository(initialUser: verifiedUser, deleteError: failure),
    );

    bloc.add(const AuthEventDeleteUser());
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateLoggedIn && state.exception != null,
    );

    expect(state.userEmail, verifiedUser.email);
    expect(state.exception, same(failure));
    await bloc.close();
  });

  test('external Firebase session changes update the app state', () async {
    final repository = _FakeAuthRepository();
    final bloc = AuthBloc(repository);

    bloc.add(const AuthEventInitialize());
    await bloc.stream.firstWhere((state) => state is AuthStateFirstTimeOpened);
    repository.emitAuthState(verifiedUser);
    await bloc.stream.firstWhere((state) => state is AuthStateLoggedIn);
    repository.emitAuthState(null);
    final state = await bloc.stream.firstWhere(
      (state) => state is AuthStateLoggingIn,
    );

    expect(state.userEmail, isNull);
    await bloc.close();
    await repository.close();
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    AuthUser? initialUser,
    this.loginUser,
    this.registrationUser,
    this.refreshedUser,
    this.initializeError,
    this.verificationError,
    this.passwordResetError,
    this.logoutError,
    this.deleteError,
  }) : _currentUser = initialUser;

  AuthUser? _currentUser;
  final AuthUser? loginUser;
  final AuthUser? registrationUser;
  final AuthUser? refreshedUser;
  final Exception? initializeError;
  final Exception? verificationError;
  final Exception? passwordResetError;
  final Exception? logoutError;
  final Exception? deleteError;
  int verificationSendCount = 0;
  String? lastLoginEmail;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> watchAuthState() => _authStateController.stream;

  void emitAuthState(AuthUser? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  Future<void> close() => _authStateController.close();

  @override
  Future<void> initialize() async {
    if (initializeError case final error?) {
      throw error;
    }
  }

  @override
  Future<AuthUser?> refreshCurrentUser() async {
    if (refreshedUser case final user?) {
      _currentUser = user;
    }
    return _currentUser;
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    return _currentUser =
        registrationUser ??
        AuthUser(id: 'user-1', email: email, isEmailVerified: false);
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    lastLoginEmail = email;
    return _currentUser =
        loginUser ??
        AuthUser(id: 'user-1', email: email, isEmailVerified: true);
  }

  @override
  Future<void> sendEmailVerification() async {
    verificationSendCount++;
    if (verificationError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (passwordResetError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> sendPasswordResetForCurrentUser() =>
      sendPasswordReset(_currentUser?.email ?? '');

  @override
  Future<void> logOut() async {
    if (logoutError case final error?) {
      throw error;
    }
    _currentUser = null;
  }

  @override
  Future<void> deleteUser() async {
    if (deleteError case final error?) {
      throw error;
    }
    _currentUser = null;
  }
}
