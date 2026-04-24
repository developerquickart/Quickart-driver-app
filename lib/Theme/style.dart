import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';

Color disabledColor = Color(0xff747474);
Color scaffoldBackgroundColor = Colors.white;
// Color primaryColor = Color(0xFF39ff26);
Color primaryColor = Color(0xff0eb50e);

//app theme
final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: scaffoldBackgroundColor,
  fontFamily: 'Poppins',
  primaryColor: primaryColor,
  dividerColor: Color(0xffF8F9FD),
  disabledColor: disabledColor,
  focusColor: Color(0xff7b49c3),
  indicatorColor: primaryColor,
  cardColor: Color(0xff222e3e),
  hintColor: Color(0xffa3a3a3),
  bottomAppBarTheme: BottomAppBarThemeData(color: kPurpleLight),
  appBarTheme: AppBarTheme(
      backgroundColor: kPurpleLight,
      elevation: 0.0,
      iconTheme: IconThemeData(color: kWhiteColor)),
  //text theme which contains all text styles
  textTheme: TextTheme(
    //default text style of Text Widget
    bodyLarge: TextStyle(),
    bodyMedium: TextStyle(),
    titleMedium: TextStyle(),
    titleSmall: TextStyle(color: disabledColor),
    displaySmall: TextStyle(),
    headlineMedium:
        TextStyle(color: scaffoldBackgroundColor, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
    // TextStyle(color: scaffoldBackgroundColor, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: disabledColor),
    bodySmall: TextStyle(),
    labelSmall: TextStyle(),
    labelLarge: TextStyle(),
  ),
  // colorScheme: ColorScheme(surface: Colors.black), bottomAppBarTheme: BottomAppBarTheme(color: Colors.white),
);

/// NAME         SIZE  WEIGHT  SPACING
/// headline1    96.0  light   -1.5
/// headline2    60.0  light   -0.5
/// headline3    48.0  regular  0.0
/// headline4    34.0  regular  0.25
/// headline5    24.0  regular  0.0
/// headline6    20.0  medium   0.15
/// subtitle1    16.0  regular  0.15
/// subtitle2    14.0  medium   0.1
/// body1        16.0  regular  0.5   (bodyText1)
/// body2        14.0  regular  0.25  (bodyText2)
/// button       14.0  medium   1.25
/// caption      12.0  regular  0.4
/// overline     10.0  regular  1.5
