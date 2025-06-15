import 'package:flutter/material.dart';
import '../services/branch_service.dart';
import '../models/branch_model.dart';

class EditBranchScreen extends StatefulWidget {
  final Branch branch;

  EditBranchScreen({required this.branch});

  @override
  _EditBranchScreenState createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _branchService = BranchService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.branch.name;
    _direccionController.text = widget.branch.address;
    _telefonoController.text = widget.branch.phone.toString();
  }

  Future<void> _updateBranch() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _branchService.updateBranch(
          widget.branch.id!,
          _nombreController.text,
          _direccionController.text,
          int.parse(_telefonoController.text),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sucursal actualizada exitosamente')),
        );
        Navigator.pop(context, true); // Volver a la pantalla anterior con éxito
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la sucursal: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Sucursal')),
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
                controller: _direccionController,
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese la dirección' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el teléfono' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateBranch,
                      child: Text('Actualizar Sucursal'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}