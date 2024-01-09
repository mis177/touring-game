import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/services/auth/firebase_auth_provider.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/views/auth/email_verify_view.dart';
import 'package:touring_game/views/auth/login_view.dart';
import 'package:touring_game/views/auth/password_forgot_view.dart';
import 'package:touring_game/views/auth/register_view.dart';
import 'package:touring_game/views/auth/start_view.dart';
import 'package:touring_game/views/game/menu_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: const {},
      debugShowCheckedModeBanner: false,
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const MenuView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggingIn) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateFirstTimeOpened) {
          return const WelcomeView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
