import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;

@immutable
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeEventInitializeTheme extends ThemeEvent {
  const ThemeEventInitializeTheme();
}

class ThemeEventChangeTheme extends ThemeEvent {
  final bool isDarkTheme;
  const ThemeEventChangeTheme(this.isDarkTheme);
}
