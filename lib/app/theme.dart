// Defines the shared font, colors, field borders and button appearance.

import 'package:flutter/material.dart';
import '../shared/colors.dart';

/// Fonts, colors and control styles shared by every screen.
ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Pretendard Variable',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: navy,
    primary: navy,
    secondary: blue,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
    hintStyle: const TextStyle(color: Color(0xffaaaaaa), fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xffe4e4e4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 2),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: blue,
      foregroundColor: navy,
      minimumSize: const Size(48, 50),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: blue,
      side: const BorderSide(color: blue, width: 2),
      minimumSize: const Size(48, 50),
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xff333333)),
  ),
);
