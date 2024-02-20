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
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/theme/themes.dart';

class ProfileInfoView extends StatefulWidget {
  const ProfileInfoView({super.key, required this.activitiesDone});

  final String? activitiesDone;

  @override
  State<ProfileInfoView> createState() => _ProfileInfoViewState();
}

class _ProfileInfoViewState extends State<ProfileInfoView> {
  bool themeSwitch = true;
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
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) async {
      if (state is AuthStateEmailSent) {
        if (state.exception != null) {
          if (state.exception is UserNotFoundException) {
            await showCustomDialog(
                context: context, title: 'Error', text: 'Email not found');
          } else {
            await showCustomDialog(
                context: context, title: 'Error', text: 'We could not proceed');
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
                context: context, title: 'Error', text: 'We could not proceed');
          }
        } else if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      }
    }, builder: (context, state) {
      if (BlocProvider.of<ThemeBloc>(context).state.themeData == lightTheme) {
        themeSwitch = false;
      }
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
                        icon: const Icon(
                          Icons.person,
                          size: 80,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Email:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                      Text(
                        state.userMail!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Your activities status:',
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(
                        widget.activitiesDone!,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.green),
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
                        value: themeSwitch,
                        onChanged: (bool value) {
                          setState(() {
                            themeSwitch = value;
                            BlocProvider.of<ThemeBloc>(context)
                                .add(ThemeEventChangeTheme(value));
                          });
                        }),
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
                              text: 'Are you sure you want to delete account?');
                          if (shouldDeleteUser == true) {
                            // ignore: use_build_context_synchronously
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
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
