import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF1F4E79);
const Color secondaryColor = Color(0xFF2E74B5);
const Color accentColor = Color(0xFF1E7B45);
const Color warningColor = Color(0xFFC55A11);
const Color bgColor = Color(0xFFF5F9FF);
const Color surfaceColor = Color(0xFFFFFFFF);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
  ),
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: const TextStyle(color: primaryColor),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: surfaceColor,
  ),
  scaffoldBackgroundColor: bgColor,
);
