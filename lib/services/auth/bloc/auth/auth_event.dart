import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:touring_game/services/auth/auth_user.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventRegister extends AuthEvent {
  const AuthEventRegister(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventShouldLogIn extends AuthEvent {
  const AuthEventShouldLogIn();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventRefreshUser extends AuthEvent {
  const AuthEventRefreshUser();
}

class AuthEventLogIn extends AuthEvent {
  const AuthEventLogIn(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventForgotPassword extends AuthEvent {
  const AuthEventForgotPassword();
}

class AuthEventPasswordResetRequested extends AuthEvent {
  const AuthEventPasswordResetRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthEventChangePassword extends AuthEvent {
  const AuthEventChangePassword();
}

class AuthEventDeleteUser extends AuthEvent {
  const AuthEventDeleteUser();
}

class AuthEventSessionChanged extends AuthEvent {
  const AuthEventSessionChanged(this.user);

  final AuthUser? user;

  @override
  List<Object?> get props => [user];
}

class AuthEventSessionError extends AuthEvent {
  const AuthEventSessionError(this.exception);

  final Exception exception;

  @override
  List<Object?> get props => [exception];
}
