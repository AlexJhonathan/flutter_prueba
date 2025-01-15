import 'package:flutter/material.dart';

class ReposteraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(title: Text('Repostera')),
      body: Center(
        child: Text(
          'Bienvenida Repostera',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}