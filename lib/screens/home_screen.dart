import 'package:flutter/material.dart';
import '../services/menu_create_service.dart';
import '../models/menu_create_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _branchIDController = TextEditingController();
  bool _status = false;
  final _menuService = MenuCreateService();
  bool _isLoading = false;

  Future<void> _createMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final menu = MenuCreate(
          name: _nameController.text,
          branchId: int.parse(_branchIDController.text),
          status: _status,
        );
        await _menuService.createMenu(menu);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menú creado exitosamente')),
        );
        _nameController.clear();
        _branchIDController.clear();
        setState(() => _status = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear el menú: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Menú')),
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
                controller: _branchIDController,
                decoration: InputDecoration(labelText: 'Branch ID'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el Branch ID' : null,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Status'),
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createMenu,
                      child: Text('Crear Menú'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}