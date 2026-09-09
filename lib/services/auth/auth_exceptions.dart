import 'package:touring_game/core/errors/app_exception.dart';

// login exceptions
class InvalidLoginCredentialsAuthException extends AuthenticationException {
  const InvalidLoginCredentialsAuthException()
    : super('The email or password is incorrect.');
}

// register exceptions
class WeakPasswordAuthException extends AuthenticationException {
  const WeakPasswordAuthException() : super('The password is too weak.');
}

class EmailAlreadyInUseAuthException extends AuthenticationException {
  const EmailAlreadyInUseAuthException()
    : super('An account already uses this email.');
}

class InvalidEmailAuthException extends AuthenticationException {
  const InvalidEmailAuthException() : super('The email address is invalid.');
}

// forgot password exceptions
class UserNotFoundException extends AuthenticationException {
  const UserNotFoundException() : super('No account uses this email.');
}

//delete account exceptions
class RequiresRecentLoginAuthException extends AuthenticationException {
  const RequiresRecentLoginAuthException()
    : super('Please sign in again before deleting the account.');
}

// generic exceptions
class GenericAuthException extends AuthenticationException {
  const GenericAuthException([Object? cause])
    : super('Authentication failed.', cause);
}

class UserNotLoggedInAuthException extends AuthenticationException {
  const UserNotLoggedInAuthException() : super('No user is signed in.');
}
