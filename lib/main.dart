import 'package:easy_nepse_calculator/providers/calculation_provider.dart';
import 'package:easy_nepse_calculator/providers/theme_provider.dart';
import 'package:easy_nepse_calculator/screens/home_screen.dart';
import 'package:easy_nepse_calculator/services/hive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  await hive.init();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => CalculationProvider(),
      ),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeProvider _themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: _themeProvider.isDarkMode
          ? ThemeData.dark()!.copyWith(
              scaffoldBackgroundColor: Colors.black,
            )
          : ThemeData.light(),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}
