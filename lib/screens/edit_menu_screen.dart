import 'package:flutter/material.dart';
import '../services/menu_create_service.dart';
import '../models/menu_list_model.dart';

class EditMenuScreen extends StatefulWidget {
  final Menu menu;

  EditMenuScreen({required this.menu});

  @override
  _EditMenuScreenState createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _selectedBranchId;
  bool _status = false;
  final _menuService = MenuCreateService();
  bool _isLoading = false;

  // Mapa de sucursales para el desplegable
  final Map<int, String> _branchOptions = {
    3: 'Tarija Principal',
    4: 'Tarija Parque',
    5: 'La Paz Principal',
    6: 'La Paz Mega',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu.name);
    
    // Verificar si el branchId existe en las opciones disponibles
    if (_branchOptions.containsKey(widget.menu.branchId)) {
      _selectedBranchId = widget.menu.branchId;
    } else {
      // Si no existe, añadir dinámicamente al mapa de opciones
      _branchOptions[widget.menu.branchId] = 'Sucursal ${widget.menu.branchId}';
      _selectedBranchId = widget.menu.branchId;
    }
    
    _status = widget.menu.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _menuService.updateMenu(
          widget.menu.id,
          _nameController.text,
          _selectedBranchId,
          _status ? 1 : 0,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menú actualizado exitosamente')),
        );
        
        // Regresamos a la pantalla anterior con un resultado exitoso
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el menú: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Menú')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
              ),
              SizedBox(height: 16),
              // Desplegable para sucursales
              DropdownButtonFormField<int>(
                value: _selectedBranchId,
                decoration: InputDecoration(
                  labelText: 'Sucursal',
                  border: OutlineInputBorder(),
                ),
                items: _branchOptions.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedBranchId = value;
                    });
                  }
                },
                validator: (value) => value == null ? 'Seleccione una sucursal' : null,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Estado'),
                subtitle: Text(_status ? 'Activo' : 'Inactivo'),
                value: _status,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateMenu,
                      child: Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                        backgroundColor: Colors.blue,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}