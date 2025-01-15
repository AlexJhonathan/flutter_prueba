import 'package:flutter/material.dart';
import '../services/employee_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final _employeeService = EmployeeService();
  bool _isLoading = false;

  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final response = await _employeeService.addEmployee(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        int.parse(_roleController.text), // Asegurar que el role sea numérico
      );

      setState(() => _isLoading = false);

      if (response.error.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleado añadido exitosamente')),
        );
        Navigator.pop(context); // Volver a la pantalla anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Añadir Empleado')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el email' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese la contraseña' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Rol'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el rol' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addEmployee,
                      child: Text('Añadir Empleado'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}