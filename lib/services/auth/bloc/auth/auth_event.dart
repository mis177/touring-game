import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(this.email, this.password);
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

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
  @override
  List<Object?> get props => [email];
}

class AuthEventChangePassword extends AuthEvent {
  const AuthEventChangePassword();
  @override
  List<Object?> get props => [];
}

class AuthEventDeleteUser extends AuthEvent {
  const AuthEventDeleteUser();
  @override
  List<Object?> get props => [];
}
