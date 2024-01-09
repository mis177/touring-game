import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

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
            if (state.exception is UserNotFound) {
              await showCustomDialog(
                  context: context, title: 'Error', text: 'Email not found');
            } else {
              await showCustomDialog(
                  context: context,
                  title: 'Error',
                  text: 'We could not proceed');
            }
          } else if (state.emailSent == true) {
            _controller.clear();
            await showCustomDialog(
                context: context,
                title: 'Success',
                text: 'Email was sent successfully');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.amber,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter email and click password reset',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Your email adress',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              FilledButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: const Text('Reset password'),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text('Back to login page'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
