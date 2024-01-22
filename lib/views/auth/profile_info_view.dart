import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
import 'package:touring_game/utilities/dialogs/logout_dialog.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';

class ProfileInfoView extends StatefulWidget {
  const ProfileInfoView({super.key});

  @override
  State<ProfileInfoView> createState() => _ProfileInfoViewState();
}

class _ProfileInfoViewState extends State<ProfileInfoView> {
  void showSnackBar(String text) {
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
        if (state is AuthStateEmailSent) {
          if (state.exception != null) {
            if (state.exception is UserNotFoundException) {
              await showCustomDialog(
                  context: context, title: 'Error', text: 'Email not found');
            } else {
              await showCustomDialog(
                  context: context,
                  title: 'Error',
                  text: 'We could not proceed');
            }
          } else {
            showSnackBar('Password reset email was sent to you');
          }
        } else if (state is AuthStateUserDeleting) {
          if (state.exception != null) {
            if (state.exception is RequiresRecentLoginAuthException) {
              await showCustomDialog(
                  context: context, title: 'Error', text: 'You need to relog');
            } else {
              await showCustomDialog(
                  context: context,
                  title: 'Error',
                  text: 'We could not proceed');
            }
          } else if (state.isLoading) {
            LoadingScreen().show(
                context: context,
                text: state.loadingText ?? 'Please wait a moment');
          } else {
            LoadingScreen().hide();
          }
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn ||
            state is AuthStateEmailSent ||
            state is AuthStateUserDeletedError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  IconButton.filled(
                    icon: const Icon(
                      Icons.person,
                      size: 80,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Email:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(state.userMail!),
                  const SizedBox(height: 100),
                  ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventChangePassword(),
                            );
                      },
                      child: const Text('Reset password')),
                  const SizedBox(height: 25),
                  ElevatedButton(
                      onPressed: () async {
                        final shouldDeleteUser = await showLogoutDialog(
                            context: context,
                            title: 'Delete',
                            text: 'Are you sure you want to delete account?');
                        if (shouldDeleteUser == true) {
                          // ignore: use_build_context_synchronously
                          context.read<AuthBloc>().add(
                                const AuthEventDeleteUser(),
                              );
                        }
                      },
                      child: const Text(
                        'Delete account',
                        style: TextStyle(color: Colors.red),
                      )),
                ],
              ),
            ),
          );
        } else {
          return const Text('');
        }
      },
    );
  }
}
