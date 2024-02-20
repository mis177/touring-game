import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touring_game/services/theme/bloc/theme_event.dart';
import 'package:touring_game/services/theme/bloc/theme_state.dart';
import 'package:touring_game/utilities/theme/themes.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeStateUninitialized()) {
    on<ThemeEventInitializeTheme>((event, emit) async {
      emit(ThemeStateThemeChanging());
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool? isDarkTheme = prefs.getBool("is_dark_theme");

      ThemeData stateTheme;
      if (isDarkTheme != true) {
        stateTheme = getTheme(false);
      } else {
        stateTheme = getTheme(true);
      }

      emit(
        ThemeStateThemeChanged(themeData: stateTheme),
      );
    });

    on<ThemeEventChangeTheme>((event, emit) async {
      bool isDarkTheme = event.isDarkTheme;
      emit(ThemeStateThemeChanging());
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("is_dark_theme", isDarkTheme);
      emit(
        ThemeStateThemeChanged(themeData: getTheme(isDarkTheme)),
      );
    });
  }
}
