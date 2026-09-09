sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.cause]);
}

class DataException extends AppException {
  const DataException(super.message, [super.cause]);
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

class LocationException extends AppException {
  const LocationException(super.message, [super.cause]);
}

class PreferencesException extends AppException {
  const PreferencesException(super.message, [super.cause]);
}

class MediaException extends AppException {
  const MediaException(super.message, [super.cause]);
}

class ExternalNavigationException extends AppException {
  const ExternalNavigationException(super.message, [super.cause]);
}
