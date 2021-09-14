
import 'package:efs_new/pages/appScreens/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final MaterialColor primaryColor = const MaterialColor(
    0xff022b5e,
    const <int, Color>{
      50: const Color(0xff022b5e),
      100: const Color(0xff022b5e),
      200: const Color(0xff022b5e),
      300: const Color(0xff022b5e),
      400: const Color(0xff022b5e),
      500: const Color(0xff022b5e),
      600: const Color(0xff022b5e),
      700: const Color(0xff022b5e),
      800: const Color(0xff022b5e),
      900: const Color(0xff022b5e),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
