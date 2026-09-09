class FirebaseServiceException implements Exception {
  const FirebaseServiceException({this.code, required this.cause});

  final String? code;
  final Object cause;
}
