import 'package:easy_nepse_calculator/main.dart';
import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = (hive.getBool("_isDarkTheme",
      defaultValue:
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark));

  String _language =
      hive.getString("language") == "" ? "English" : hive.getString("language");

  String get language => _language;

  setLanguage(String value) async {
    await hive.setString("language", value);
    _language = value;
    if (value == "English") {
      localization.translate(
        "en",
      );
    } else {
      localization.translate(
        "ने",
      );
    }

    notifyListeners();
  }

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
