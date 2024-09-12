import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Themes {
  lightThemeGreenBlue,
  darkThemeSoftGray,
  lightCleanSoftBlue,
  modernDarkBlueOrange,
  softGreenWarmGray,
  classicMinimalBlackWhiteRed,
}

getCurrentTheme(Themes _theme) {
  switch (_theme) {
    case Themes.softGreenWarmGray:
      return softGreenWarmGray;
    case Themes.modernDarkBlueOrange:
      return modernDarkBlueOrange;
    case Themes.lightThemeGreenBlue:
      return lightThemeGreenBlue;
    case Themes.lightCleanSoftBlue:
      return lightCleanSoftBlue;
    case Themes.darkThemeSoftGray:
      return darkThemeSoftGray;
    case Themes.classicMinimalBlackWhiteRed:
      return classicMinimalBlackWhiteRed;

    default:
      softGreenWarmGray;
  }
}

final ThemeData lightThemeGreenBlue = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2B7A78), // Teal
  // accentColor: const Color(0xFF3AAFA9), // Light Green
  // backgroundColor: const Color(0xFFDEF2F1), // Very Light Cyan
  scaffoldBackgroundColor: const Color(0xFFDEF2F1), // Same as background color
  // textTheme: GoogleFonts.robotoTextTheme(),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF2B7A78), // Teal for AppBar

    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF2B7A78), // Teal for buttons
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xFF3AAFA9)), // Light green for focused input
    ),
  ),
);

final ThemeData darkThemeSoftGray = ThemeData(
  // textTheme: GoogleFonts.robotoTextTheme(),

  brightness: Brightness.dark,
  primaryColor: const Color(0xFF283149), // Deep Navy Blue
  // accentColor: const Color(0xFFF73859), // Vibrant Pinkish Red
  // backgroundColor: const Color(0xFF404B69), // Slate Gray
  scaffoldBackgroundColor: const Color(0xFF404B69), // Same as background color

  appBarTheme: const AppBarTheme(
    color: Color(0xFF283149), // Deep Navy Blue for AppBar

    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFF73859), // Vibrant Pinkish Red for buttons
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF404B69), // Slate Gray for input fields
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xFFF73859)), // Pinkish Red for focused input
    ),
  ),
);

final ThemeData lightCleanSoftBlue = ThemeData(
  // textTheme: GoogleFonts.robotoTextTheme(),

  brightness: Brightness.light,
  primaryColor: const Color(0xFF6C63FF), // Soft Blue
  // accentColor: const Color(0xFFFFD700), // Golden
  // backgroundColor: const Color(0xFFF7F7F7), // Very Light Gray
  scaffoldBackgroundColor: const Color(0xFFF7F7F7), // Same as background color

  appBarTheme: const AppBarTheme(
    color: Color(0xFF6C63FF), // Soft Blue for AppBar

    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF6C63FF), // Soft Blue for buttons
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xFFFFD700)), // Golden for focused input
    ),
  ),
);

final ThemeData modernDarkBlueOrange = ThemeData(
  // textTheme: GoogleFonts.robotoTextTheme(),

  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1E1E2C), // Very Dark Blue
  // accentColor: const Color(0xFFFF9505), // Vibrant Orange
  // backgroundColor: const Color(0xFF2D2D44), // Slate Blue
  scaffoldBackgroundColor: const Color(0xFF2D2D44), // Same as background color

  appBarTheme: const AppBarTheme(
    color: Color(0xFF1E1E2C), // Very Dark Blue for AppBar

    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFFF9505), // Vibrant Orange for buttons
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E1E2C), // Dark Blue for inputs
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xFFFF9505)), // Orange for focused input
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF9505), // Orange for FAB
  ),
);

final ThemeData softGreenWarmGray = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF3D8361), // Soft Green
  // accentColor: const Color(0xFFFFCD38), // Warm Yellow
  // backgroundColor: const Color(0xFFF5F5F5), // Very Light Gray
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Same as background color

  appBarTheme: const AppBarTheme(
    color: Color(0xFF3D8361), // Soft Green for AppBar

    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF3D8361), // Soft Green for buttons
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xFFFFCD38)), // Warm Yellow for focused input
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFCD38), // Warm Yellow for FAB
  ),
);

final ThemeData classicMinimalBlackWhiteRed = ThemeData(
  // textTheme: GoogleFonts.robotoTextTheme(),

  brightness: Brightness.light,
  primaryColor: const Color(0xFF000000), // Black
  // accentColor: const Color(0xFFE63946), // Bright Red
  // backgroundColor: const Color(0xFFF2F2F2), // Very Light Gray
  scaffoldBackgroundColor: const Color(0xFFF2F2F2), // Same as background color

  appBarTheme: const AppBarTheme(
    color: Color(0xFF000000), // Black for AppBar

    iconTheme: IconThemeData(color: Colors.white),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFE63946), // Bright Red for buttons
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xFFE63946)), // Bright Red for focused input
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFE63946), // Bright Red for FAB
  ),
);
