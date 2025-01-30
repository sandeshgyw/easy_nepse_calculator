import 'package:easy_nepse_calculator/mixins/localization.dart';
import 'package:easy_nepse_calculator/screens/home_page.dart';
import 'package:easy_nepse_calculator/screens/language_selector_screen.dart';
import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:easy_nepse_calculator/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (hive.getBool("isLanguageSet")) {
        navigateToPage(context: context, pageName: HomeScreen());
      } else {
        navigateToPage(context: context, pageName: LanguageSelectionScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color:
            isDarkMode ? Colors.black : Colors.white, // Theme-based background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo with Rounded Borders
            ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners
              child: Image.asset(
                "assets/icon/logo.png",
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // App Title
            Text(
              AppLocale.title.getString(context),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? Colors.white
                    : Colors.black, // Theme-based text color
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // Subtext or Tagline
            Text(
              AppLocale.simplifyStockCalculations.getString(context),
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode
                    ? Colors.white70
                    : Colors.black87, // Theme-based subtext color
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
