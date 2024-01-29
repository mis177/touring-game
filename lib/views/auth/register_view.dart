import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool obscureText = true;
  IconData visibilityIcon = Icons.visibility;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showCustomDialog(
                context: context, title: 'Error', text: 'Weak password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showCustomDialog(
                context: context,
                title: 'Error',
                text: 'Email is already in use');
          } else if (state.exception is GenericAuthException) {
            await showCustomDialog(
                context: context, title: 'Error', text: 'Failed to register');
          } else if (state.exception is InvalidEmailAuthException) {
            await showCustomDialog(
                context: context, title: 'Error', text: 'Invalid email');
          } else if (state.isLoading) {
            LoadingScreen().show(
                context: context,
                text: state.loadingText ?? 'Please wait a moment');
          } else {
            LoadingScreen().hide();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: Image.asset('lib/images/app_icon.png'),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Touring app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    alignLabelWithHint: true,
                    labelText: 'Enter your email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _password,
                  obscureText: obscureText,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(visibilityIcon),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                          if (obscureText) {
                            visibilityIcon = Icons.visibility;
                          } else {
                            visibilityIcon = Icons.visibility_off;
                          }
                        });
                      },
                    ),
                    alignLabelWithHint: true,
                    labelText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800]),
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(
                          AuthEventRegister(
                            email,
                            password,
                          ),
                        );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventShouldLogIn());
                  },
                  child: Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                            text: 'Already registered? ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                          text: ' Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
