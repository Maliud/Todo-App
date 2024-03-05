import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

  class CustomTheme {
    static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.deepPurple,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,

      cupertinoOverrideTheme: const CupertinoThemeData(brightness: Brightness.dark)
    );

    static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.deepPurple,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[900],
     cupertinoOverrideTheme: const CupertinoThemeData(brightness: Brightness.dark)
    );
  }
