import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

enum AuthFeedback {
  verificationEmailSent,
  passwordResetEmailSent,
  accountDeleted,
}

@immutable
sealed class AuthState extends Equatable {
  const AuthState({
    this.userEmail,
    this.isLoading = false,
    this.loadingText,
    this.exception,
    this.feedback,
  });

  final String? userEmail;
  final bool isLoading;
  final String? loadingText;
  final Exception? exception;
  final AuthFeedback? feedback;

  @override
  List<Object?> get props => [
    userEmail,
    isLoading,
    loadingText,
    exception,
    feedback,
  ];
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({super.isLoading});
}

class AuthStateFirstTimeOpened extends AuthState {
  const AuthStateFirstTimeOpened();
}

class AuthStateRegistering extends AuthState {
  const AuthStateRegistering({
    super.isLoading,
    super.loadingText,
    super.exception,
  });
}

class AuthStateLoggingIn extends AuthState {
  const AuthStateLoggingIn({
    super.isLoading,
    super.loadingText,
    super.exception,
    super.feedback,
  });
}

class AuthStateLoggedIn extends AuthState {
  const AuthStateLoggedIn({
    required String userEmail,
    super.isLoading,
    super.loadingText,
    super.exception,
    super.feedback,
  }) : super(userEmail: userEmail);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    super.userEmail,
    super.isLoading,
    super.loadingText,
    super.exception,
    super.feedback,
  });
}

class AuthStateForgotPassword extends AuthState {
  const AuthStateForgotPassword({
    super.isLoading,
    super.loadingText,
    super.exception,
    super.feedback,
  });
}
