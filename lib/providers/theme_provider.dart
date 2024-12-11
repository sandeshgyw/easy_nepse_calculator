import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = (hive.getBool("_isDarkTheme",
      defaultValue:
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark));

  bool get isDarkMode => _isDarkTheme;

  getInitialThemeState() {
    _isDarkTheme = (hive.getBool("_isDarkTheme",
        defaultValue:
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark));
    notifyListeners();
  }

  Future changeTheme(bool isDark) async {
    await hive.setBool("_isDarkTheme", isDark);
    _isDarkTheme = hive.getBool("_isDarkTheme");
    notifyListeners();
  }
}
