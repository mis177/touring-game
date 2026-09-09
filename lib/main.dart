import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:touring_game/services/auth/auth_exceptions.dart';
import 'package:touring_game/services/auth/auth_repository.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_bloc.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';
import 'package:touring_game/services/theme/bloc/theme_bloc.dart';
import 'package:touring_game/services/theme/bloc/theme_event.dart';
import 'package:touring_game/services/theme/bloc/theme_state.dart';
import 'package:touring_game/services/theme/shared_preferences_theme_repository.dart';
import 'package:touring_game/services/theme/theme_repository.dart';
import 'package:touring_game/services/auth/firebase_auth_repository.dart';
import 'package:touring_game/services/demo/demo_auth_repository.dart';
import 'package:touring_game/services/demo/demo_game_repository.dart';
import 'package:touring_game/services/demo/demo_map_repositories.dart';
import 'package:touring_game/services/firebase/auth_service.dart';
import 'package:touring_game/services/firebase/file_storage_service.dart';
import 'package:touring_game/services/firebase/game_data_service.dart';
import 'package:touring_game/services/firebase/user_data_service.dart';
import 'package:touring_game/services/game/firebase_game_repository.dart';
import 'package:touring_game/services/game/game_repository.dart';
import 'package:touring_game/services/map/location_repository.dart';
import 'package:touring_game/services/map/location_search_repo.dart';
import 'package:touring_game/services/map/place_search_repository.dart';
import 'package:touring_game/services/media/image_picker_repository.dart';
import 'package:touring_game/services/navigation/external_url_repository.dart';
import 'package:touring_game/utilities/loading_screen/loading_screen.dart';
import 'package:touring_game/utilities/dialogs/auth_dialog.dart';
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
import 'package:touring_game/utilities/map/current_location.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const isDemoMode = bool.fromEnvironment('DEMO_MODE');
  if (isDemoMode) {
    runApp(
      TouringGameApp(
        authRepository: DemoAuthRepository(),
        gameRepository: DemoGameRepository(),
        searchRepository: DemoPlaceSearchRepository(),
        locationRepository: const DemoLocationRepository(),
        imagePickerRepository: DeviceImagePickerRepository(),
        externalUrlRepository: const DeviceExternalUrlRepository(),
        themeRepository: const SharedPreferencesThemeRepository(),
        isDemoMode: true,
      ),
    );
    return;
  }

  final authService = FirebaseAuthService();
  final storageService = FirebaseFileStorageService();
  runApp(
    TouringGameApp(
      authRepository: FirebaseAuthRepository(
        authService: authService,
        userDataService: FirebaseUserDataService(),
        storageService: storageService,
      ),
      gameRepository: FirebaseGameRepository(
        authService: authService,
        dataService: FirebaseGameDataService(),
        storageService: storageService,
      ),
      searchRepository: LocationSearchRepository(),
      locationRepository: const GeolocatorLocationRepository(),
      imagePickerRepository: DeviceImagePickerRepository(),
      externalUrlRepository: const DeviceExternalUrlRepository(),
      themeRepository: const SharedPreferencesThemeRepository(),
    ),
  );
}

class TouringGameApp extends StatelessWidget {
  const TouringGameApp({
    super.key,
    required this.authRepository,
    required this.gameRepository,
    required this.searchRepository,
    required this.locationRepository,
    required this.imagePickerRepository,
    required this.externalUrlRepository,
    required this.themeRepository,
    this.isDemoMode = false,
  });

  final AuthRepository authRepository;
  final GameRepository gameRepository;
  final PlaceSearchRepository searchRepository;
  final LocationRepository locationRepository;
  final ImagePickerRepository imagePickerRepository;
  final ExternalUrlRepository externalUrlRepository;
  final ThemeRepository themeRepository;
  final bool isDemoMode;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<GameRepository>(create: (_) => gameRepository),
        RepositoryProvider<CatalogRepository>(
          create: (context) => context.read<GameRepository>(),
        ),
        RepositoryProvider<ActivityProgressRepository>(
          create: (context) => context.read<GameRepository>(),
        ),
        RepositoryProvider<NotesRepository>(
          create: (context) => context.read<GameRepository>(),
        ),
        RepositoryProvider<PlaceSearchRepository>(
          create: (_) => searchRepository,
          dispose: (repository) => repository.close(),
        ),
        RepositoryProvider<LocationRepository>(
          create: (_) => locationRepository,
        ),
        RepositoryProvider<ImagePickerRepository>(
          create: (_) => imagePickerRepository,
        ),
        RepositoryProvider<ExternalUrlRepository>(
          create: (_) => externalUrlRepository,
        ),
        RepositoryProvider<ThemeRepository>(create: (_) => themeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ThemeBloc(context.read<ThemeRepository>())
                  ..add(const ThemeEventInitializeTheme()),
          ),
          BlocProvider(
            create: (context) =>
                AuthBloc(context.read<AuthRepository>())
                  ..add(const AuthEventInitialize()),
          ),
        ],
        child: _AppView(isDemoMode: isDemoMode),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView({required this.isDemoMode});

  final bool isDemoMode;

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: homeRoute, builder: (context, state) => const HomePage()),
      GoRoute(
        path: activitiesListRoute,
        builder: (context, state) {
          final arguments = state.extra;
          return arguments is ActivitiesListArguments
              ? ActivitiesListProvider(arguments: arguments)
              : const _InvalidRouteArguments();
        },
      ),
      GoRoute(
        path: activityDetailsRoute,
        builder: (context, state) {
          final arguments = state.extra;
          return arguments is ActivityDetailsArguments
              ? ActivityDetailsProvider(arguments: arguments)
              : const _InvalidRouteArguments();
        },
      ),
      GoRoute(
        path: userNotesRoute,
        builder: (context, state) {
          final arguments = state.extra;
          return arguments is UserNotesArguments
              ? UserNotesBlocProvider(arguments: arguments)
              : const _InvalidRouteArguments();
        },
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) => MaterialApp.router(
        routerConfig: _router,
        theme: state.themeData,
        title: 'Visiter',
        debugShowCheckedModeBanner: false,
        builder: (context, child) => widget.isDemoMode
            ? Banner(
                message: 'DEMO',
                location: BannerLocation.topEnd,
                child: child ?? const SizedBox.shrink(),
              )
            : child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class _InvalidRouteArguments extends StatelessWidget {
  const _InvalidRouteArguments();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page unavailable')),
      body: const Center(
        child: Text('This page cannot be opened without activity data.'),
      ),
    );
  }
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state.feedback == AuthFeedback.accountDeleted) {
          showSnackBar('Account deleted');
        } else if (state is AuthStateLoggingIn && state.exception != null) {
          final message = switch (state.exception) {
            InvalidLoginCredentialsAuthException() => 'Invalid credentials',
            InvalidEmailAuthException() => 'Invalid email',
            _ => 'Authentication failed. Please try again.',
          };
          await showCustomDialog(
            context: context,
            title: 'Error',
            text: message,
          );
        }
      },
      builder: (context, state) {
        final Widget content;
        if (state is AuthStateLoggedIn) {
          content = const AppMenuView();
        } else if (state is AuthStateNeedsVerification) {
          content = const VerifyEmailView();
        } else if (state is AuthStateLoggingIn) {
          content = const LoginView();
        } else if (state is AuthStateForgotPassword) {
          content = const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          content = const RegisterView();
        } else if (state is AuthStateFirstTimeOpened) {
          content = const WelcomeView();
        } else {
          content = const Scaffold(body: SizedBox.shrink());
        }
        return LoadingOverlay(
          isLoading: state.isLoading,
          text: state.loadingText ?? 'Please wait a moment',
          child: content,
        );
      },
    );
  }
}
