import 'package:flutter/material.dart' show immutable;
import 'package:touring_game/services/auth/auth_user.dart';

@immutable
sealed class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    this.isLoading = false,
    this.loadingText = 'Please wait a moment',
  });
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({bool isLoading = false})
      : super(isLoading: isLoading);
}

class AuthStateFirstTimeOpened extends AuthState {
  const AuthStateFirstTimeOpened({bool isLoading = false})
      : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({
    this.exception,
    bool isLoading = false,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );
}

class AuthStateLoggingIn extends AuthState {
  final Exception? exception;
  const AuthStateLoggingIn({
    this.exception,
    bool isLoading = false,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, bool isLoading = false})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({bool isLoading = false})
      : super(isLoading: isLoading);
}

class AuthStateForgotPassword extends AuthState {
  final bool emailSent;
  final Exception? exception;
  const AuthStateForgotPassword({
    this.exception,
    this.emailSent = false,
    bool isLoading = false,
  }) : super(isLoading: isLoading);
}
