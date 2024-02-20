import 'package:flutter/material.dart';

sealed class ThemeState {
  ThemeData? themeData;
  ThemeState({this.themeData});
}

class ThemeStateUninitialized extends ThemeState {
  ThemeStateUninitialized();
}

class ThemeStateThemeChanging extends ThemeState {
  ThemeStateThemeChanging();
}

class ThemeStateThemeChanged extends ThemeState {
  ThemeStateThemeChanged({super.themeData});
}
