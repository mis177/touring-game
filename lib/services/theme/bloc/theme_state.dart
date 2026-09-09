import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

sealed class ThemeState extends Equatable {
  final ThemeData? themeData;
  final Exception? exception;
  const ThemeState({this.themeData, this.exception});

  @override
  List<Object?> get props => [themeData, exception];
}

class ThemeStateUninitialized extends ThemeState {
  const ThemeStateUninitialized();
}

class ThemeStateThemeChanged extends ThemeState {
  const ThemeStateThemeChanged({super.themeData, super.exception});
}
