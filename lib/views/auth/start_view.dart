import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: Image.asset('lib/images/app_icon.png'),
            ),
            Text(
              'Visiter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Image.asset('lib/images/traveller.png'),
            ),
            const Text(
              'Hello traveler!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
            const Text(
              'This is an app for people who like to travel, discover new places and are not boomers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const Text(
              "Sounds good? Let's hop in!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: Colors.blueGrey[800]),
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventShouldRegister(),
                    );
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 36),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueGrey[800]),
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventShouldLogIn(),
                    );
              },
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
