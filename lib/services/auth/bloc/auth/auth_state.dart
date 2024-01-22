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
  const AuthStateUninitialized({super.isLoading});
}

class AuthStateFirstTimeOpened extends AuthState {
  const AuthStateFirstTimeOpened({super.isLoading});
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class AuthStateLoggingIn extends AuthState {
  final Exception? exception;
  const AuthStateLoggingIn({
    this.exception,
    super.isLoading,
    super.loadingText = null,
  });
}

class AuthStateLoggedIn extends AuthState {
  final String userEmail;
  const AuthStateLoggedIn({required this.userEmail, super.isLoading})
      : super(userMail: userEmail);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({super.isLoading});
}

class AuthStateForgotPassword extends AuthState {
  final bool emailSent;
  final Exception? exception;
  const AuthStateForgotPassword({
    this.exception,
    this.emailSent = false,
    super.isLoading,
  });
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
    super.isLoading,
    this.exception,
    super.loadingText = null,
  });
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
