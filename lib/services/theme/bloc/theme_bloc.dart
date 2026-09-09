import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:touring_game/services/theme/bloc/theme_event.dart';
import 'package:touring_game/services/theme/bloc/theme_state.dart';
import 'package:touring_game/services/theme/theme_repository.dart';
import 'package:touring_game/utilities/theme/themes.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._repository) : super(const ThemeStateUninitialized()) {
    on<ThemeEventInitializeTheme>((event, emit) async {
      try {
        final isDarkTheme = await _repository.loadIsDarkTheme();
        _isDarkTheme = isDarkTheme;
        emit(ThemeStateThemeChanged(themeData: getTheme(isDarkTheme)));
      } on Exception catch (error) {
        emit(
          ThemeStateThemeChanged(themeData: getTheme(false), exception: error),
        );
      }
    }, transformer: restartable());

    on<ThemeEventChangeTheme>((event, emit) async {
      final isDarkTheme = event.isDarkTheme;
      try {
        await _repository.saveIsDarkTheme(isDarkTheme);
        _isDarkTheme = isDarkTheme;
        emit(ThemeStateThemeChanged(themeData: getTheme(isDarkTheme)));
      } on Exception catch (error) {
        emit(
          ThemeStateThemeChanged(
            themeData: getTheme(_isDarkTheme),
            exception: error,
          ),
        );
      }
    }, transformer: sequential());
  }

  final ThemeRepository _repository;
  bool _isDarkTheme = false;
}
