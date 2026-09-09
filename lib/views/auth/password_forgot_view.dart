import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
import 'package:touring_game/views/auth/auth_form_layout.dart';
import 'package:touring_game/views/auth/auth_form_validators.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.exception != null) {
            if (state.exception is InvalidEmailAuthException) {
              await showCustomDialog(
                context: context,
                title: 'Error',
                text: 'Invalid email',
              );
            } else {
              await showCustomDialog(
                context: context,
                title: 'Error',
                text: 'We could not proceed',
              );
            }
          } else if (state.feedback == AuthFeedback.passwordResetEmailSent) {
            _controller.clear();
            await showCustomDialog(
              context: context,
              title: 'Success',
              text:
                  'If an account exists for this email, a reset link was sent.',
            );
          }
        }
      },
      child: Scaffold(
        body: AuthScrollableBody(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthLogo(),
                const SizedBox(height: 25),
                const Text(
                  'Enter email and click password reset',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  validator: validateEmail,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Your email address',
                    prefixIcon: Icon(Icons.email),
                    alignLabelWithHint: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Reset password'),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventShouldLogIn());
                  },
                  child: const Text('Back to login page'),
                ),
              ],
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
      AuthEventPasswordResetRequested(_controller.text),
    );
  }
}
