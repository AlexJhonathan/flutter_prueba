import 'package:flutter/material.dart';

class MeseraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(title: Text('Mesera')),
      body: Center(
        child: Text(
          'Bienvenida Mesera',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}