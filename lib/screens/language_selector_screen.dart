import 'dart:typed_data';
import 'dart:ui';

import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/providers/theme_provider.dart';
import 'package:easy_nepse_calculator/screens/home_page.dart';
import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:easy_nepse_calculator/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  String get selectedLanguage =>
      hive.getString("language") == "" ? "English" : hive.getString("language");

  @override
  Widget build(BuildContext context) {
    ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners
              child: Lottie.asset(
                'assets/icon/logo_stable_lottie.json',
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Select your preferred language.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "आफ्नो मनपर्ने भाषा चयन गर्नुहोस्।",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await _themeProvider.setLanguage("English");
                await hive.setBool("isLanguageSet", true);
                navigateToPage(context: context, pageName: HomeScreen());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text("English"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _themeProvider.setLanguage("Nepali");
                await hive.setBool("isLanguageSet", true);
                navigateToPage(context: context, pageName: HomeScreen());
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text("नेपाली"),
            ),
          ],
        ),
      ),
    );
  }
}
