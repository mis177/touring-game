import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Colors.grey[300]!,
      primaryContainer: Colors.grey[800],
      secondaryContainer: Colors.grey[200],
      tertiaryContainer: Colors.blue[800],
      background: Colors.black,
      surface: Colors.grey[800]!,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(color: Colors.grey[900]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.amber[800]),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[800],
    ),
    cardTheme: CardTheme(
      color: Colors.grey[800],
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.green[700],
    ),
    iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.black))));

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.blueGrey[800]!,
    primaryContainer: Colors.grey[200],
    secondaryContainer: Colors.grey[900],
    tertiaryContainer: Colors.blue[800],
    background: Colors.grey[300]!,
    surface: Colors.grey[200]!,
    onSurface: Colors.black,
  ),
  scaffoldBackgroundColor: Colors.grey[300],
  appBarTheme: AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.grey[300],
    titleTextStyle: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
  ),
  popupMenuTheme: PopupMenuThemeData(color: Colors.grey[50]),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[200], selectedItemColor: Colors.amber[800]),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey[100],
  ),
  cardTheme: CardTheme(
    color: Colors.grey[100],
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.green,
  ),
);

ThemeData getTheme(bool isDarkTheme) {
  if (isDarkTheme) {
    return darkTheme;
  } else {
    return lightTheme;
  }
}
