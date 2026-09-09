import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/services/theme/bloc/theme_bloc.dart';
import 'package:touring_game/services/theme/bloc/theme_event.dart';
import 'package:touring_game/services/theme/bloc/theme_state.dart';
import 'package:touring_game/services/theme/theme_repository.dart';

void main() {
  test(
    'theme initialization falls back to light when preferences fail',
    () async {
      final failure = Exception('read failed');
      final bloc = ThemeBloc(_FakeThemeRepository(loadError: failure));

      bloc.add(const ThemeEventInitializeTheme());
      final state =
          await bloc.stream.firstWhere(
                (state) => state is ThemeStateThemeChanged,
              )
              as ThemeStateThemeChanged;

      expect(state.themeData?.brightness, Brightness.light);
      expect(state.exception, same(failure));
      await bloc.close();
    },
  );

  test('theme changes are persisted before success is emitted', () async {
    final repository = _FakeThemeRepository();
    final bloc = ThemeBloc(repository);

    bloc.add(const ThemeEventChangeTheme(true));
    final state =
        await bloc.stream.firstWhere((state) => state is ThemeStateThemeChanged)
            as ThemeStateThemeChanged;

    expect(repository.savedValue, isTrue);
    expect(state.themeData?.brightness, Brightness.dark);
    expect(state.exception, isNull);
    await bloc.close();
  });
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository({this.loadError});

  final Exception? loadError;
  bool? savedValue;

  @override
  Future<bool> loadIsDarkTheme() async {
    if (loadError case final error?) {
      throw error;
    }
    return false;
  }

  @override
  Future<void> saveIsDarkTheme(bool isDarkTheme) async {
    savedValue = isDarkTheme;
  }
}
