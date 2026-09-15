import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/firebase_auth_repository.dart';
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/firebase_service_exception.dart';

import '../helpers/fake_firebase_services.dart';

void main() {
  test('maps an authentication service error to a domain exception', () async {
    final authService = FakeAuthService()
      ..error = const FirebaseServiceException(
        code: 'invalid-credential',
        cause: 'invalid credential',
      );
    final repository = FirebaseAuthRepository(authService: authService);

    expect(
      () => repository.logIn(email: 'user@example.com', password: 'wrong'),
      throwsA(isA<InvalidLoginCredentialsAuthException>()),
    );
  });

  test('does not disclose whether a login email exists', () async {
    final authService = FakeAuthService()
      ..error = const FirebaseServiceException(
        code: 'user-not-found',
        cause: 'user not found',
      );
    final repository = FirebaseAuthRepository(authService: authService);

    expect(
      () => repository.logIn(email: 'missing@example.com', password: 'wrong'),
      throwsA(isA<InvalidLoginCredentialsAuthException>()),
    );
  });

  test(
    'deleting an account deletes authentication before backend cleanup',
    () async {
      final authService = FakeAuthService(
        user: AuthServiceUser(
          id: 'user-1',
          email: 'user@example.com',
          isEmailVerified: true,
          lastSignInTime: DateTime.now(),
        ),
      );
      final repository = FirebaseAuthRepository(authService: authService);

      await repository.deleteUser();

      expect(authService.userDeleted, isTrue);
      expect(authService.currentUser, isNull);
    },
  );

  test('failed authentication deletion keeps the account active', () async {
    final authService = FakeAuthService(
      user: AuthServiceUser(
        id: 'user-1',
        email: 'user@example.com',
        isEmailVerified: true,
        lastSignInTime: DateTime.now(),
      ),
    );
    authService.deleteError = const FirebaseServiceException(
      code: 'unavailable',
      cause: 'offline',
    );
    final repository = FirebaseAuthRepository(authService: authService);

    await expectLater(
      repository.deleteUser(),
      throwsA(isA<GenericAuthException>()),
    );
    expect(authService.userDeleted, isFalse);
    expect(authService.currentUser, isNotNull);
  });
}
