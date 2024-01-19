import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AuthState {
  final bool isLoading;
  final String? loadingText;
  final String? userMail;
  const AuthState({
    this.userMail,
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
  final String userEmail;
  const AuthStateLoggedIn({required this.userEmail, bool isLoading = false})
      : super(isLoading: isLoading, userMail: userEmail);
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

class AuthStateEmailSent extends AuthState {
  final Exception? exception;
  final String userEmail;
  const AuthStateEmailSent({
    required this.exception,
    required this.userEmail,
  }) : super(userMail: userEmail);
}

class AuthStateUserDeleting extends AuthState {
  final Exception? exception;
  const AuthStateUserDeleting({
    bool isLoading = false,
    this.exception,
    String? loadingText,
  }) : super(
          isLoading: isLoading,
          loadingText: loadingText,
        );
}

class AuthStateUserDeletedError extends AuthState {
  final Exception? exception;
  const AuthStateUserDeletedError({
    this.exception,
  });
}

class AuthStateUserDeleted extends AuthState {
  const AuthStateUserDeleted();
}
