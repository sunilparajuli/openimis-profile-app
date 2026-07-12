
import 'package:flutter/cupertino.dart';

import 'dark_theme_preference.dart';
import 'custom_theme.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    CustomTheme.setTheme(value);
    notifyListeners();
  }
}