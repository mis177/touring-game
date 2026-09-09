import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/views/auth/auth_form_layout.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final verificationState = state is AuthStateNeedsVerification
            ? state
            : null;
        final error = verificationState?.exception;
        final statusMessage = error != null
            ? error is AppException
                  ? error.message
                  : 'Something went wrong. Please try again.'
            : verificationState?.feedback == AuthFeedback.verificationEmailSent
            ? 'Verification email sent.'
            : null;

        return Scaffold(
          body: AuthScrollableBody(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthLogo(),
                const SizedBox(height: 25),
                const Text(
                  'Verify your email address to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 25),
                const Text(
                  "If you didn't get email click button below",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 25),
                if (statusMessage != null) ...[
                  Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: error == null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                FilledButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventRefreshUser());
                  },
                  child: const Text("I've verified my email"),
                ),
                const SizedBox(height: 15),
                FilledButton.tonal(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
                  },
                  child: const Text('Send email verification'),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text('Back to login page'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
