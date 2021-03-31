import 'package:flutter/material.dart';

Color primaryColor = Colors.orange[800];
//Color primaryColor = Color.fromARGB(255, 58, 149, 255);
Color reallyLightGrey = Colors.grey.withAlpha(25);
ThemeData appThemeLight =
    ThemeData.light().copyWith(
        primaryColor: primaryColor,
//        appBarTheme: AppBarTheme(
//            color: Colors.white,
//            iconTheme: IconThemeData(color: Colors.orange[800])
//        )
    );
ThemeData appThemeDark = ThemeData.dark().copyWith(
    primaryColor: Colors.white,
    toggleableActiveColor: primaryColor,
    accentColor: primaryColor,
    buttonColor: primaryColor,
    textSelectionColor: primaryColor,
    textSelectionHandleColor: primaryColor);
