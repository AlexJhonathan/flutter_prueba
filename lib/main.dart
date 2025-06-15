import 'package:flutter/material.dart';
import 'package:flutter_prueba/models/menu_list_model.dart';
import 'package:flutter_prueba/pages/first_page.dart';
import 'package:flutter_prueba/pages/home_page.dart';
import 'package:flutter_prueba/pages/settings_page.dart';
import 'package:flutter_prueba/pages/auth/login_page.dart';
import 'package:flutter_prueba/pages/auth/register_page.dart';
import 'package:flutter_prueba/pages/admin/admin_page.dart';
import 'package:flutter_prueba/pages/admin/personal/personal_list.dart';
import 'package:flutter_prueba/pages/admin/branches/branch_list.dart';
import 'package:flutter_prueba/pages/admin/menu/menus_list.dart';
import 'package:flutter_prueba/pages/admin/menu/menus_products_list.dart';
import 'package:flutter_prueba/pages/admin/menu/product_list.dart';
import 'package:flutter_prueba/pages/admin/reports/reports_page.dart';
import 'package:flutter_prueba/pages/admin/supplies/supplies_list.dart';

import 'package:flutter_prueba/screens/login_screen.dart';
import 'package:flutter_prueba/screens/list_supplies_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {

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
        '/adminpage': (context) => AdminPage(),
        '/personallist': (context) => PersonalList(),
        '/branchlist': (context) => BranchList(),
        '/menuslist': (context) => MenusList(),
        '/reportspage': (context) => ReportsPage(),
        '/supplieslist': (context) => SuppliesList(),
        '/productlist': (context) => ProductList(),


        '/loginscreen': (context) => LoginScreen(),
        '/listsuppliesscreen': (context) => ListSuppliesScreen(),
      }
    );
  }
}
