import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/demo/demo_auth_repository.dart';
import 'package:touring_game/services/demo/demo_game_repository.dart';
import 'package:touring_game/views/auth/email_verify_view.dart';
import 'package:touring_game/views/auth/login_view.dart';
import 'package:touring_game/views/auth/start_view.dart';

import '../helpers/fake_app_dependencies.dart';
import '../helpers/fake_game_repository.dart';

void main() {
  testWidgets('demo mode opens a populated app without authentication setup', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        authRepository: DemoAuthRepository(),
        gameRepository: DemoGameRepository(),
        isDemoMode: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Banner && widget.message == 'DEMO',
      ),
      findsOneWidget,
    );
    expect(find.text('Kraków'), findsOneWidget);
    expect(find.text('Warsaw'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('app injects dependencies and opens the login view', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      buildTestApp(
        authRepository: FakeAuthRepository(),
        gameRepository: FakeGameRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeView), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.text('Log In to your account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'registration remains authenticated when verification email sending fails',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestApp(
          authRepository: FakeAuthRepository(
            verificationError: const GenericAuthException(),
          ),
          gameRepository: FakeGameRepository(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Sign Up'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'traveler@example.com');
      await tester.enterText(fields.at(1), 'secure-password');
      await tester.enterText(fields.at(2), 'secure-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(VerifyEmailView), findsOneWidget);
      expect(find.text('Authentication failed.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('login form scrolls and validates on a small screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthBloc(FakeAuthRepository()),
        child: const MaterialApp(home: LoginView()),
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, 'Log In');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Enter your email'), findsNWidgets(2));
    expect(find.text('Enter your password'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
