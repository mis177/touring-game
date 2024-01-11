import 'package:bloc/bloc.dart';
import 'package:touring_game/services/auth/auth_service.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_event.dart';
import 'package:touring_game/services/auth/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthService service)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await service.initialize();
      final user = service.currentUser;
      if (user == null) {
        emit(
          const AuthStateFirstTimeOpened(),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(
          user: user,
        ));
      }
    });

    //back to register view
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering());
    });

    //back to login view
    on<AuthEventShouldLogIn>((event, emit) {
      emit(const AuthStateLoggingIn());
    });

    //register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      emit(const AuthStateRegistering(
          isLoading: true, loadingText: 'Creating account'));
      try {
        await service.createUser(
          email: email,
          password: password,
        );
        await service.sendEmailVeryfication();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
        ));
      }
    });

    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggingIn(isLoading: true, loadingText: 'Logging in'),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await service.logIn(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          await service.sendEmailVeryfication();
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(
            user: user,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggingIn(
            exception: e,
          ),
        );
      }
    });
    // log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await service.logOut();
        emit(
          const AuthStateLoggingIn(),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggingIn(
            exception: e,
          ),
        );
      }
    });

    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword());
      final email = event.email;
      if (email == null) {
        return;
      }

      emit(const AuthStateForgotPassword(
        isLoading: true,
      ));
      Exception? exception;
      bool emailSent;
      try {
        await service.sendPasswordReset(toEmail: email);
        exception = null;
        emailSent = true;
      } on Exception catch (e) {
        exception = e;
        emailSent = false;
      }
      emit(AuthStateForgotPassword(
        exception: exception,
        emailSent: emailSent,
      ));
    });
    //send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await service.sendEmailVeryfication();
      emit(const AuthStateNeedsVerification());
    });
  }
}
