// login exceptions
class InvalidLoginCredentialsAuthException implements Exception {}

// register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// forgot password exceptions
class UserNotFoundException implements Exception {}

//delete account exceptions
class RequiresRecentLoginAuthException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
