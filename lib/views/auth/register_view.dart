import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
import 'package:touring_game/views/auth/auth_form_layout.dart';
import 'package:touring_game/views/auth/auth_form_validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordConfirm;
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordConfirm = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showCustomDialog(
              context: context,
              title: 'Error',
              text: 'Weak password',
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showCustomDialog(
              context: context,
              title: 'Error',
              text: 'Email is already in use',
            );
          } else if (state.exception is GenericAuthException) {
            await showCustomDialog(
              context: context,
              title: 'Error',
              text: 'Failed to register',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showCustomDialog(
              context: context,
              title: 'Error',
              text: 'Invalid email',
            );
          } else if (state.exception != null) {
            await showCustomDialog(
              context: context,
              title: 'Error',
              text: 'Failed to register. Please try again.',
            );
          }
        }
      },
      child: Scaffold(
        body: AuthScrollableBody(
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AuthLogo(),
                  const SizedBox(height: 25),
                  Text(
                    'Visiter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _email,
                    validator: validateEmail,
                    autofillHints: const [AutofillHints.newUsername],
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      alignLabelWithHint: true,
                      labelText: 'Enter your email',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _password,
                    validator: validatePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    obscureText: obscureText,
                    enableSuggestions: false,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                      alignLabelWithHint: true,
                      labelText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordConfirm,
                    validator: (value) {
                      final passwordError = validatePassword(value);
                      if (passwordError != null) {
                        return passwordError;
                      }
                      return value == _password.text
                          ? null
                          : 'Passwords do not match';
                    },
                    autofillHints: const [AutofillHints.newPassword],
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Confirm your password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 36),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const AuthEventShouldLogIn(),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          const TextSpan(text: 'Already registered? '),
                          TextSpan(
                            text: ' Log in',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
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
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthBloc>().add(
      AuthEventRegister(_email.text, _password.text),
    );
  }
}
