import 'package:flutter/material.dart';
import '../services/supply_category_service.dart'; // Importar el servicio

class RegistrarInsumoScreen extends StatefulWidget {
  @override
  _RegistrarInsumoScreenState createState() => _RegistrarInsumoScreenState();
}

class _RegistrarInsumoScreenState extends State<RegistrarInsumoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController(); // Controlador para categoría

  final SupplyCategoryService _supplyCategoryService = SupplyCategoryService(); // Instancia del servicio

  Future<void> _guardarInsumo() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final unidad = _unidadController.text;
      final categoria = _categoriaController.text;

      try {
        await _supplyCategoryService.registrarInsumo(nombre, unidad, categoria);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insumo registrado exitosamente')),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el insumo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar un Nuevo Insumo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _unidadController,
                decoration: InputDecoration(
                  labelText: 'Unidad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la unidad';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la categoría';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarInsumo,
                child: Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Regresar a la pantalla anterior
                },
                child: Text('Atrás'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}