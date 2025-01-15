import 'package:flutter/material.dart';
import 'package:flutter_prueba/pages/cook/cook_page.dart';
import 'package:flutter_prueba/pages/first_page.dart';
import 'package:flutter_prueba/pages/home_page.dart';
import 'package:flutter_prueba/pages/settings_page.dart';
import 'package:flutter_prueba/pages/auth/login_page.dart';
import 'package:flutter_prueba/pages/auth/register_page.dart';
import 'package:flutter_prueba/pages/waitress/waitress_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/firstpage': (context) => FisrtPage(),
        '/settingspage': (context) => SettingsPage(),
        '/loginpage': (context) => LoginPage(),
        '/registerpage': (context) => RegisterPage(),
        '/homepage': (context) => HomePage(),
        '/cookpage': (context) => CookPage(),
        '/waitresspage': (context) => WaitressPage(),
      }
    );
  }
}
