
import 'package:flutter/material.dart';

class AppTheme  {

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
    backgroundColor: white,
    primaryColor: primary,
    accentColor: Colors.blueAccent,
    scaffoldBackgroundColor: Color(0xFFEFEFF2),
    bottomAppBarColor: white,
    cardColor: white,
    focusColor: primary,
    splashColor: Colors.white24,
    buttonColor: primary,
    primaryTextTheme: _lightTextTheme,
    accentTextTheme: _lightTextTheme,
    dividerColor: whiteGray,
    cursorColor: darkGray,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0)
      )
    ),
    iconTheme: IconThemeData(
      color: darkGray
    )
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    textTheme: _darkTextTheme,
    backgroundColor: black,
    primaryColor: primary,
    accentColor: Colors.blueAccent,
    scaffoldBackgroundColor: black,
    bottomAppBarColor: bottomBar,
    cardColor: blackGray,
    focusColor: primary,
    splashColor: Colors.white24,
    buttonColor: primary,
    primaryTextTheme: _darkTextTheme,
    accentTextTheme: _darkTextTheme,
    dividerColor: darkGray,
    cursorColor: white,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0)
      )
    ),
    iconTheme: IconThemeData(
      color: lightGray
    )
  );

  static TextTheme _lightTextTheme = TextTheme(
    headline1: _headline1.merge(blackStyle),
    headline2: _headline2.merge(blackStyle),
    headline3: _headline3.merge(blackStyle),
    headline4: _headline4.merge(blackGrayStyle),
    headline5: _headline5.merge(blackGrayStyle),
    headline6: _headline6.merge(blackGrayStyle),
    subtitle1: _subtitle1.merge(blackGrayStyle),
    subtitle2: _subtitle2.merge(blackGrayStyle),
    bodyText1: _body1.merge(darkGrayStyle),
    bodyText2: _body2.merge(grayStyle),
    caption: _caption.merge(grayStyle),
    button: _button.merge(grayStyle),
    overline: _overline.merge(lightGrayStyle)
  );

  static TextTheme _darkTextTheme = TextTheme(
    headline1: _headline1.merge(whiteStyle),
    headline2: _headline2.merge(whiteStyle),
    headline3: _headline3.merge(whiteStyle),
    headline4: _headline4.merge(whiteStyle),
    headline5: _headline5.merge(whiteStyle),
    headline6: _headline6.merge(whiteStyle),
    subtitle1: _subtitle1.merge(whiteStyle),
    subtitle2: _subtitle2.merge(whiteStyle),
    bodyText1: _body1.merge(whiteStyle),
    bodyText2: _body2.merge(whiteGrayStyle),
    caption: _caption.merge(lightGrayStyle),
    button: _button.merge(whiteStyle),
    overline: _overline.merge(grayStyle)
  );

  // *****************************************************
  // * Font and Font size
  // ***************************************************** 

  static const TextStyle _headline1 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w300,
    fontSize: 96,
    letterSpacing: -1.5,
  );

  static const TextStyle _headline2 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w300,
    fontSize: 60,
    letterSpacing: -0.5,
  );
  
  static const TextStyle _headline3 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 48,
    letterSpacing: 0,
  );

  static const TextStyle _headline4 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 34,
    letterSpacing: 0.25,
  );

  static const TextStyle _headline5 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    letterSpacing: 0,
  );

  static const TextStyle _headline6 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: 0.15,
  );

  static const TextStyle _subtitle1 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.15,
  );

  static const TextStyle _subtitle2 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.1,
  );

  static const TextStyle _body1 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.5,
  );

  static const TextStyle _body2 = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
  );

  static const TextStyle _button = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 1.25,
  );

  static const TextStyle _caption = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
  );

  static const TextStyle _overline = const TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 10,
    letterSpacing: 1.5,
  );

  // *****************************************************
  // * Font Weight
  // ***************************************************** 
  static const TextStyle normal = const TextStyle(
    fontWeight: FontWeight.w400,
  );

  static const TextStyle medium = const TextStyle(
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bold = const TextStyle(
    fontWeight: FontWeight.w700,
  );

  // *****************************************************
  // * Text Colot Style
  // ***************************************************** 
  static const TextStyle whiteStyle = const TextStyle(
    color: white
  );

  static const TextStyle whiteGrayStyle = const TextStyle(
    color: whiteGray
  );

  static const TextStyle lightGrayStyle = const TextStyle(
    color: lightGray
  );

  static const TextStyle grayStyle = const TextStyle(
    color: gray
  );

  static const TextStyle darkGrayStyle = const TextStyle(
    color: darkGray
  );

  static const TextStyle blackGrayStyle = const TextStyle(
    color: blackGray
  );

  static const TextStyle blackStyle = const TextStyle(
    color: black
  );

  static const TextStyle primaryStyle = const TextStyle(
    color: primary
  );

  static const TextStyle primaryLightStyle = const TextStyle(
    color: primaryLight
  );

  static const TextStyle primaryDarkStyle = const TextStyle(
    color: primaryDark
  );

  static const TextStyle attensionStyle = const TextStyle(
    color: attension
  );

}