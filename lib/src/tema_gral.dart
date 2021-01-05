library buscocard.globals;
import 'package:flutter/material.dart';

String nombreApp = 'BuscoCard';

// Azul = 0xff0070B3
// Naranja = 0xffCEB800

// Generales
Color primaryColor = const Color(0xffffffff);
Color textOverPrimary = const Color(0xff000000);

// --------------------------------------------- Page::init_config_page
String splashIntroColor = 'gradient';
LinearGradient splashGradient = LinearGradient(
  colors: [
    const Color(0xff0070B3),
    const Color(0xff00FFFF),
    const Color(0xffCEB800),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter
);
Color splashSolid = Colors.blue;

Color splashStatusTopBarrSystem = const Color(0xff0070B3);
Color splashBarrBottomColor = const Color(0xffCEB800);
Brightness splashBarIconColor = Brightness.dark;

// --------------------------------------------- Page::base_index_page
Color statusTopBarrSystem = const Color(0xffFFFFFF);
Color baseBarrBottomColor = const Color(0xffFFFFFF);
Brightness baseBarIconColor = Brightness.dark;
