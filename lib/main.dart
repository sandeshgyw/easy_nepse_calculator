import 'package:easy_nepse_calculator/constants/theme.dart';
import 'package:easy_nepse_calculator/screens/home_screen.dart';
import 'package:flutter/material.dart';

Themes currentTheme = Themes.darkThemeSoftGray;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: getCurrentTheme(currentTheme),
      // theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Easy Share Calculator'),
    );
  }
}
