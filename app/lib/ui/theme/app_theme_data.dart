import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFFA000);
  static const Color primaryLight = Color(0xFFFFD149);
  static const Color primaryDark = Color(0xFFC67100);

  // static const Color primary = Color(0xFF1565C0);
  // static const Color primaryLight = Color(0xFF5E92F3);
  // static const Color primaryDark = Color(0xFF003c8f);

  // App Gray Scale
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteGray = Color(0xFFCACACA);
  static const Color lightGray = Color(0xFFAAAAAA);
  static const Color gray = Color(0xFF808080);
  static const Color darkGray = Color(0xFF555555);
  static const Color blackGray = Color(0xFF242424);
  static const Color black = Color(0xFF000000);

  static const Color bottomBar = Color(0xFF151515);

  // App Standard
  static const Color high = Color(0xFFEF5350);
  static const Color low = Color(0xFF42A5F5);
  static const Color highAlpha = Color(0x66EF5350);
  static const Color lowAlpha = Color(0x6642A5F5);
  static const Color attension = Color(0xFF9E1212);

  // Font
  static const String fontName = 'Nunito';

  static ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    textTheme: _lightTextTheme,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFFEFEFF2),
    cardColor: white,
    focusColor: primary,
    splashColor: Colors.white24,
    primaryTextTheme: _lightTextTheme,
    dividerColor: whiteGray,
    cardTheme: CardTheme(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
    iconTheme: const IconThemeData(color: darkGray),
    bottomAppBarTheme: const BottomAppBarTheme(color: white),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    textTheme: _darkTextTheme,
    primaryColor: primary,
    scaffoldBackgroundColor: black,
    cardColor: blackGray,
    focusColor: primary,
    splashColor: Colors.white24,
    primaryTextTheme: _darkTextTheme,
    dividerColor: darkGray,
    cardTheme: CardTheme(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
    iconTheme: const IconThemeData(color: lightGray),
    bottomAppBarTheme: const BottomAppBarTheme(color: bottomBar),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
  );

  static final TextTheme _lightTextTheme = TextTheme(
      displayLarge: _headline1.merge(blackStyle),
      displayMedium: _headline2.merge(blackStyle),
      displaySmall: _headline3.merge(blackStyle),
      headlineMedium: _headline4.merge(blackGrayStyle),
      headlineSmall: _headline5.merge(blackGrayStyle),
      titleLarge: _headline6.merge(blackGrayStyle),
      titleMedium: _subtitle1.merge(blackGrayStyle),
      titleSmall: _subtitle2.merge(blackGrayStyle),
      bodyLarge: _body1.merge(darkGrayStyle),
      bodyMedium: _body2.merge(grayStyle),
      bodySmall: _caption.merge(grayStyle),
      labelLarge: _button.merge(grayStyle),
      labelSmall: _overline.merge(lightGrayStyle));

  static final TextTheme _darkTextTheme = TextTheme(
      displayLarge: _headline1.merge(whiteStyle),
      displayMedium: _headline2.merge(whiteStyle),
      displaySmall: _headline3.merge(whiteStyle),
      headlineMedium: _headline4.merge(whiteStyle),
      headlineSmall: _headline5.merge(whiteStyle),
      titleLarge: _headline6.merge(whiteStyle),
      titleMedium: _subtitle1.merge(whiteStyle),
      titleSmall: _subtitle2.merge(whiteStyle),
      bodyLarge: _body1.merge(whiteStyle),
      bodyMedium: _body2.merge(whiteGrayStyle),
      bodySmall: _caption.merge(lightGrayStyle),
      labelLarge: _button.merge(whiteStyle),
      labelSmall: _overline.merge(grayStyle));

  // *****************************************************
  // * Font and Font size
  // *****************************************************

  static const TextStyle _headline1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w300,
    fontSize: 96,
    letterSpacing: -1.5,
  );

  static const TextStyle _headline2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w300,
    fontSize: 60,
    letterSpacing: -0.5,
  );

  static const TextStyle _headline3 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 48,
    letterSpacing: 0,
  );

  static const TextStyle _headline4 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 34,
    letterSpacing: 0.25,
  );

  static const TextStyle _headline5 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    letterSpacing: 0,
  );

  static const TextStyle _headline6 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: 0.15,
  );

  static const TextStyle _subtitle1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.15,
  );

  static const TextStyle _subtitle2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.1,
  );

  static const TextStyle _body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.5,
  );

  static const TextStyle _body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
  );

  static const TextStyle _button = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 1.25,
  );

  static const TextStyle _caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
  );

  static const TextStyle _overline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 10,
    letterSpacing: 1.5,
  );

  // *****************************************************
  // * Font Weight
  // *****************************************************
  static const TextStyle normal = TextStyle(
    fontWeight: FontWeight.w400,
  );

  static const TextStyle medium = TextStyle(
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bold = TextStyle(
    fontWeight: FontWeight.w700,
  );

  // *****************************************************
  // * Text Colot Style
  // *****************************************************
  static const TextStyle whiteStyle = TextStyle(color: white);

  static const TextStyle whiteGrayStyle = TextStyle(color: whiteGray);

  static const TextStyle lightGrayStyle = TextStyle(color: lightGray);

  static const TextStyle grayStyle = TextStyle(color: gray);

  static const TextStyle darkGrayStyle = TextStyle(color: darkGray);

  static const TextStyle blackGrayStyle = TextStyle(color: blackGray);

  static const TextStyle blackStyle = TextStyle(color: black);

  static const TextStyle primaryStyle = TextStyle(color: primary);

  static const TextStyle primaryLightStyle = TextStyle(color: primaryLight);

  static const TextStyle primaryDarkStyle = TextStyle(color: primaryDark);

  static const TextStyle attensionStyle = TextStyle(color: attension);
}
