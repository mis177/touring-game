import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/auth_repository.dart';
import 'package:touring_game/services/auth/auth_user.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository)
    : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEvent>(_onEvent, transformer: sequential());
  }

  final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _sessionSubscription;

  Future<void> _onEvent(AuthEvent event, Emitter<AuthState> emit) async {
    switch (event) {
      case AuthEventInitialize():
        await _initialize(emit);
      case AuthEventShouldRegister():
        emit(const AuthStateRegistering());
      case AuthEventShouldLogIn():
        emit(const AuthStateLoggingIn());
      case AuthEventRegister():
        await _register(event, emit);
      case AuthEventLogIn():
        await _logIn(event, emit);
      case AuthEventLogOut():
        await _logOut(emit);
      case AuthEventForgotPassword():
        emit(const AuthStateForgotPassword());
      case AuthEventPasswordResetRequested():
        await _resetPassword(event, emit);
      case AuthEventSendEmailVerification():
        await _sendEmailVerification(emit);
      case AuthEventRefreshUser():
        await _refreshUser(emit);
      case AuthEventChangePassword():
        await _resetCurrentUserPassword(emit);
      case AuthEventDeleteUser():
        await _deleteUser(emit);
      case AuthEventSessionChanged():
        _sessionChanged(event, emit);
      case AuthEventSessionError():
        emit(_sessionStateAfterFailure(state, event.exception));
    }
  }

  Future<void> _initialize(Emitter<AuthState> emit) async {
    try {
      await _repository.initialize();
      await _sessionSubscription?.cancel();
      _sessionSubscription = _repository.watchAuthState().listen(
        (user) => add(AuthEventSessionChanged(user)),
        onError: (Object error) => add(
          AuthEventSessionError(
            error is Exception ? error : GenericAuthException(error),
          ),
        ),
      );
      final user = _repository.currentUser;
      emit(
        user == null ? const AuthStateFirstTimeOpened() : _stateForUser(user),
      );
    } on Exception catch (error) {
      emit(AuthStateLoggingIn(exception: error));
    }
  }

  Future<void> _register(
    AuthEventRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      const AuthStateRegistering(
        isLoading: true,
        loadingText: 'Creating account',
      ),
    );
    try {
      final user = await _repository.createUser(
        email: event.email.trim(),
        password: event.password,
      );
      if (user.isEmailVerified) {
        emit(AuthStateLoggedIn(userEmail: user.email));
        return;
      }
      try {
        await _repository.sendEmailVerification();
        emit(
          AuthStateNeedsVerification(
            userEmail: user.email,
            feedback: AuthFeedback.verificationEmailSent,
          ),
        );
      } on Exception catch (error) {
        emit(
          AuthStateNeedsVerification(userEmail: user.email, exception: error),
        );
      }
    } on Exception catch (error) {
      emit(AuthStateRegistering(exception: error));
    }
  }

  Future<void> _logIn(AuthEventLogIn event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoggingIn(isLoading: true, loadingText: 'Logging in'));
    try {
      final user = await _repository.logIn(
        email: event.email.trim(),
        password: event.password,
      );
      emit(_stateForUser(user));
    } on Exception catch (error) {
      emit(AuthStateLoggingIn(exception: error));
    }
  }

  Future<void> _logOut(Emitter<AuthState> emit) async {
    final previousState = state;
    emit(_loadingSessionState('Logging out'));
    try {
      await _repository.logOut();
      emit(const AuthStateLoggingIn());
    } on Exception catch (error) {
      emit(_sessionStateAfterFailure(previousState, error));
    }
  }

  Future<void> _resetPassword(
    AuthEventPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      const AuthStateForgotPassword(
        isLoading: true,
        loadingText: 'Sending password reset email',
      ),
    );
    try {
      await _repository.sendPasswordReset(event.email.trim());
      emit(
        const AuthStateForgotPassword(
          feedback: AuthFeedback.passwordResetEmailSent,
        ),
      );
    } on UserNotFoundException {
      emit(
        const AuthStateForgotPassword(
          feedback: AuthFeedback.passwordResetEmailSent,
        ),
      );
    } on Exception catch (error) {
      emit(AuthStateForgotPassword(exception: error));
    }
  }

  Future<void> _sendEmailVerification(Emitter<AuthState> emit) async {
    final email = state.userEmail;
    emit(
      AuthStateNeedsVerification(
        userEmail: email,
        isLoading: true,
        loadingText: 'Sending verification email',
      ),
    );
    try {
      await _repository.sendEmailVerification();
      emit(
        AuthStateNeedsVerification(
          userEmail: email,
          feedback: AuthFeedback.verificationEmailSent,
        ),
      );
    } on Exception catch (error) {
      emit(AuthStateNeedsVerification(userEmail: email, exception: error));
    }
  }

  Future<void> _refreshUser(Emitter<AuthState> emit) async {
    final email = state.userEmail;
    emit(
      AuthStateNeedsVerification(
        userEmail: email,
        isLoading: true,
        loadingText: 'Checking verification status',
      ),
    );
    try {
      final user = await _repository.refreshCurrentUser();
      if (user == null) {
        emit(
          const AuthStateLoggingIn(exception: UserNotLoggedInAuthException()),
        );
      } else {
        emit(_stateForUser(user));
      }
    } on Exception catch (error) {
      emit(_sessionStateAfterFailure(state, error));
    }
  }

  Future<void> _resetCurrentUserPassword(Emitter<AuthState> emit) async {
    final previousState = state;
    emit(_loadingSessionState('Sending password reset email'));
    try {
      await _repository.sendPasswordResetForCurrentUser();
      final user = _repository.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggingIn(exception: UserNotLoggedInAuthException()),
        );
      } else {
        emit(
          _stateForUser(user, feedback: AuthFeedback.passwordResetEmailSent),
        );
      }
    } on Exception catch (error) {
      emit(_sessionStateAfterFailure(previousState, error));
    }
  }

  Future<void> _deleteUser(Emitter<AuthState> emit) async {
    final previousState = state;
    emit(_loadingSessionState('Deleting account'));
    try {
      await _repository.deleteUser();
      emit(const AuthStateLoggingIn(feedback: AuthFeedback.accountDeleted));
    } on Exception catch (error) {
      emit(_sessionStateAfterFailure(previousState, error));
    }
  }

  AuthState _stateForUser(
    AuthUser user, {
    Exception? exception,
    AuthFeedback? feedback,
  }) {
    return user.isEmailVerified
        ? AuthStateLoggedIn(
            userEmail: user.email,
            exception: exception,
            feedback: feedback,
          )
        : AuthStateNeedsVerification(
            userEmail: user.email,
            exception: exception,
            feedback: feedback,
          );
  }

  void _sessionChanged(AuthEventSessionChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user == null) {
      if (state is AuthStateLoggedIn || state is AuthStateNeedsVerification) {
        emit(const AuthStateLoggingIn());
      }
      return;
    }

    final alreadyCurrent =
        state.userEmail == user.email &&
        ((state is AuthStateLoggedIn && user.isEmailVerified) ||
            (state is AuthStateNeedsVerification && !user.isEmailVerified));
    if (!alreadyCurrent) {
      emit(_stateForUser(user));
    }
  }

  AuthState _loadingSessionState(String loadingText) {
    final email = state.userEmail;
    return state is AuthStateNeedsVerification
        ? AuthStateNeedsVerification(
            userEmail: email,
            isLoading: true,
            loadingText: loadingText,
          )
        : AuthStateLoggedIn(
            userEmail: email ?? '',
            isLoading: true,
            loadingText: loadingText,
          );
  }

  AuthState _sessionStateAfterFailure(
    AuthState previousState,
    Exception error,
  ) {
    try {
      final user = _repository.currentUser;
      if (user != null) {
        return _stateForUser(user, exception: error);
      }
    } on Exception {
      // Preserve the last known session state below.
    }
    if (previousState is AuthStateNeedsVerification) {
      return AuthStateNeedsVerification(
        userEmail: previousState.userEmail,
        exception: error,
      );
    }
    if (previousState is AuthStateLoggedIn) {
      return AuthStateLoggedIn(
        userEmail: previousState.userEmail ?? '',
        exception: error,
      );
    }
    return AuthStateLoggingIn(exception: error);
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
