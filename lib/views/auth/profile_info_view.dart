import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/services/theme/bloc/theme_bloc.dart';
import 'package:touring_game/services/theme/bloc/theme_event.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
import 'package:touring_game/utilities/dialogs/logout_dialog.dart';

class ProfileInfoView extends StatelessWidget {
  const ProfileInfoView({super.key, required this.activitiesDone});

  final String? activitiesDone;

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedIn) {
          if (state.exception != null) {
            if (state.exception is RequiresRecentLoginAuthException) {
              await showCustomDialog(
                context: context,
                title: 'Error',
                text: 'Sign in again before deleting your account.',
              );
            } else {
              await showCustomDialog(
                context: context,
                title: 'Error',
                text: 'We could not proceed',
              );
            }
          } else if (state.feedback == AuthFeedback.passwordResetEmailSent) {
            showSnackBar(context, 'Password reset email was sent to you');
          }
        }
      },
      builder: (context, state) {
        final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        IconButton.filled(
                          icon: const Icon(Icons.person, size: 80),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'Email:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          state.userEmail ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Your activities status:',
                          style: TextStyle(fontSize: 25),
                        ),
                        Text(
                          activitiesDone ?? '—',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Keep up good work!',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const Text('App Theme'),
                      Switch(
                        value: isDarkTheme,
                        onChanged: (bool value) {
                          context.read<ThemeBloc>().add(
                            ThemeEventChangeTheme(value),
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthEventChangePassword(),
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: const Center(child: Text('Reset password')),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          final shouldDeleteUser = await showLogoutDialog(
                            context: context,
                            title: 'Delete',
                            text: 'Are you sure you want to delete account?',
                          );
                          if (shouldDeleteUser == true) {
                            if (!context.mounted) {
                              return;
                            }
                            context.read<AuthBloc>().add(
                              const AuthEventDeleteUser(),
                            );
                          }
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: const Center(
                            child: Text(
                              'Delete account',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
