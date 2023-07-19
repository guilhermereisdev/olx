import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  primarySwatch: Colors.purple,
  primaryColor: Colors.purple,
  primaryColorDark: Colors.purple.shade700,
  appBarTheme: const AppBarTheme(color: Colors.purple),
  inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: Colors.purple,
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.purple),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.purple.shade700,
        width: 4,
      ),
    ),
  ),
);
