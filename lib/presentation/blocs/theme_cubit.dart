import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ThemeCubit extends ValueNotifier<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    if (value != mode) {
      value = mode;
    }
  }

  void toggleTheme() {
    switch (value) {
      case ThemeMode.system:
        value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        value = ThemeMode.light;
        break;
      case ThemeMode.light:
        value = ThemeMode.system;
        break;
    }
  }

  ThemeModeOption get currentOption {
    switch (value) {
      case ThemeMode.system:
        return ThemeModeOption.system;
      case ThemeMode.light:
        return ThemeModeOption.light;
      case ThemeMode.dark:
        return ThemeModeOption.dark;
    }
  }

  void setFromOption(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.system:
        value = ThemeMode.system;
        break;
      case ThemeModeOption.light:
        value = ThemeMode.light;
        break;
      case ThemeModeOption.dark:
        value = ThemeMode.dark;
        break;
    }
  }
}