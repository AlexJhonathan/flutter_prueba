import 'package:flutter/material.dart';

class InsumoReposteraScreen extends StatelessWidget {
  const InsumoReposteraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Insumos'),
      ),
      body: const Center(
        child: Text(
          'Pantalla para registrar insumos',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}