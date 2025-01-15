import 'package:flutter/material.dart';
import '../services/branch_service.dart';
import 'list_users_screen.dart';

class AddBranchScreen extends StatefulWidget {
  @override
  _AddBranchScreenState createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _branchService = BranchService();
  bool _isLoading = false;

  Future<void> _addBranch() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final response = await _branchService.addBranch(
        _nombreController.text,
        _direccionController.text,
        int.parse(_telefonoController.text),
      );

      setState(() => _isLoading = false);

      if (response.error.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sucursal añadida exitosamente')),
        );
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
      appBar: AppBar(title: Text('Añadir Sucursal')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el teléfono' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese la dirección' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addBranch,
                      child: Text('Añadir Sucursal'),
                    ),
                    SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ListUsersScreen()),
                            );
                          },
                          child: Text('Listar Usuarios'),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}