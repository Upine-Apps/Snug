import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  get darkTheme => ThemeData(
        fontFamily: 'Roboto',
        textTheme: TextTheme(
            headline1: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        )),
        dividerColor: Colors.black54, //use this for text
        primaryColor: Color(0xFFe8b5c0),
        colorScheme: ColorScheme.dark(
            primary: Color(0xFF222f5a),
            secondary: Color(0xFF5b6686),
            primaryVariant: Color(0xFF9d74ad),
            secondaryVariant: Color(0xFFe8b5c0)),
        primarySwatch: Colors.grey,
        appBarTheme: AppBarTheme(
            brightness: Brightness.dark, color: AppColors.textBlack),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: AppColors.white),
        ),
        brightness: Brightness.dark,

        accentColor: Color(0xFFe8b5c0),
        hintColor: Colors.white,
        accentIconTheme: IconThemeData(
          color: Color(0xFFe8b5c0),
        ),
      );

  get lightTheme => ThemeData(
        dividerColor: Colors.white, // use this for text

        hintColor: Colors.black54,
        // Color(0xFF5b6686),
        primaryColor: Color(0xFF5b6686),
        colorScheme: ColorScheme.light(
            primary: Color(0xFF9d74ad),
            secondary: Color(0xFFe8b5c0),
            primaryVariant: Color(0xFF222f5a),
            secondaryVariant: Color(0xFF5b6686)),
        primarySwatch: Colors.grey,
        appBarTheme: AppBarTheme(
          // brightness: Brightness.light,
          color: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.black54),
          labelStyle: TextStyle(color: Colors.black54),
        ),

        brightness: Brightness.light,
        accentColor: Color(0xFF5b6686),
        accentIconTheme: IconThemeData(
          color: Color(0xFF5b6686),
        ),
      );
}
