import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pallete {
  // Primary Colors
  static const Color forestGreen = Color(0xFF38761D);
  static const Color oliveGreen = Color(0xFF7AA353);

  // Secondary Colors
  static const Color beige = Color(0xFFC2A856);
  static const Color lightGray = Color(0xFFB2C3CB);

  // Accent Colors
  static const Color turquoise = Color(0xFF7FFBE2);
  static const Color darkSlate = Color(0xFF424444);

  static final ThemeData lightModeAppTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: forestGreen,
    accentColor: turquoise,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: forestGreen,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: oliveGreen,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: darkSlate),
      bodyText2: TextStyle(color: darkSlate),
    ),
  );

  static final ThemeData darkModeAppTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: forestGreen,
    accentColor: turquoise,
    scaffoldBackgroundColor: darkSlate,
    appBarTheme: AppBarTheme(
      color: forestGreen,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: oliveGreen,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(color: lightGray),
      bodyText2: TextStyle(color: lightGray),
    ),
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;
  ThemeNotifier({ThemeMode mode = ThemeMode.dark})
      : _mode = mode,
        super(
          mode == ThemeMode.light
              ? Pallete.lightModeAppTheme
              : Pallete.darkModeAppTheme,
        ) {
    getTheme();
  }

  ThemeMode get mode => _mode;

  Future<void> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  Future<void> toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      await prefs.setString('theme', 'light');
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      await prefs.setString('theme', 'dark');
    }
  }
}
