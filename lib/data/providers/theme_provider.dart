import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF191A1E),
  cardColor: Color(0xFF1E1E1E),
  primaryColor: Color(0xFF1DB954),
  iconTheme: IconThemeData(color: Color(0xFFE3E3E3)),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFECECEC)),
    bodyMedium: TextStyle(color: Color(0xFFE1E1E1)),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFF1DB954),
    textTheme: ButtonTextTheme.primary,
  ),
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  primaryColor: Color(0xFF6200EE),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF212121)),
    bodyMedium: TextStyle(color: Color.fromARGB(255, 55, 55, 55)),
  ),
);

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.light;

  ThemeNotifier(this._currentTheme);

  get currentTheme => _currentTheme;

  changeTheme() {
    if (_currentTheme == ThemeMode.light) {
      _currentTheme = ThemeMode.dark;
    } else {
      _currentTheme = ThemeMode.light;
    }

    notifyListeners();
  }
}
