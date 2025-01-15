import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(title: Text('Administrador')),
      body: Center(
        child: Text(
          'Bienvenido Administrador',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}