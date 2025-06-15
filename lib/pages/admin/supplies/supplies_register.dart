import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_category_service.dart';

class SuppliesRegister extends StatefulWidget {
  @override
  _SuppliesRegisterState createState() => _SuppliesRegisterState();
}

class _SuppliesRegisterState extends State<SuppliesRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  final SupplyCategoryService _supplyCategoryService = SupplyCategoryService();

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
        Navigator.pop(context);
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
      backgroundColor: Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        backgroundColor: Color(0xFFED7A9E),
        title: Text('Registrar un Nuevo Insumo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre',
                    validatorMessage: 'Por favor, ingrese el nombre',
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _unidadController,
                    label: 'Unidad',
                    validatorMessage: 'Por favor, ingrese la unidad',
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _categoriaController,
                    label: 'Categoría',
                    validatorMessage: 'Por favor, ingrese la categoría',
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardarInsumo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 236, 113, 158),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Guardar', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Atrás', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }
}
