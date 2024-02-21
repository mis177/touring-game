import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/auth_service.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/services/theme/bloc/theme_bloc.dart';
import 'package:touring_game/services/theme/bloc/theme_event.dart';
import 'package:touring_game/services/theme/bloc/theme_state.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/routes.dart';
import 'package:touring_game/views/auth/email_verify_view.dart';
import 'package:touring_game/views/auth/login_view.dart';
import 'package:touring_game/views/auth/password_forgot_view.dart';
import 'package:touring_game/views/auth/register_view.dart';
import 'package:touring_game/views/auth/start_view.dart';
import 'package:touring_game/views/game/activities/activities_list_view.dart';
import 'package:touring_game/views/game/activities/activity_detail_view.dart';
import 'package:touring_game/views/game/activities/notes_view.dart';
import 'package:touring_game/views/game/menu_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
        create: (context) =>
            ThemeBloc()..add(const ThemeEventInitializeTheme()),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              theme: state.themeData,
              title: 'Visiter',
              home: BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(AuthService.firebase()),
                child: const HomePage(),
              ),
              routes: {
                openActivitiesList: (context) =>
                    const ActivitiesListBlocProvider(),
                openActivitityDetails: (context) =>
                    const ActivityDetailsBlocProvider(),
                openUserNotes: (context) => const UserNotesBlocProvider(),
              },
              debugShowCheckedModeBanner: false,
            );
          },
        )),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state.isLoading) {
          LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment');
        } else {
          LoadingScreen().hide();
        }

        if (state is AuthStateUserDeletedError) {
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
          }
        } else if (state is AuthStateUserDeleted) {
          showSnackBar('Account deleted');
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn || state is AuthStateEmailSent) {
          return const AppMenuView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggingIn ||
            state is AuthStateUserDeletedError) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering ||
            state is AuthStateUserDeleted) {
          return const RegisterView();
        } else if (state is AuthStateFirstTimeOpened) {
          return const WelcomeView();
        } else {
          return const Scaffold(
            body: Text(''),
          );
        }
      },
    );
  }
}
