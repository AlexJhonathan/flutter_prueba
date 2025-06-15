import 'package:flutter/material.dart';
import '../services/menu_create_service.dart';
import '../models/menu_create_model.dart';

class CreateMenuScreen extends StatefulWidget {
  @override
  _CreateMenuScreenState createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late int _selectedBranchId; // Cambiado de TextEditingController a int
  bool _status = false;
  final _menuService = MenuCreateService();
  bool _isLoading = false;
  
  // Mapa de sucursales para el desplegable (mismo que en edit_menu_screen.dart)
  final Map<int, String> _branchOptions = {
    3: 'Tarija Principal',
    4: 'Tarija Parque',
    5: 'La Paz Principal',
    6: 'La Paz Mega',
  };

  @override
  void initState() {
    super.initState();
    // Establecer un valor predeterminado para la sucursal
    _selectedBranchId = _branchOptions.keys.first; // 3: Tarija Principal por defecto
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Crear el modelo con los valores del formulario
        final menu = MenuCreate(
          name: _nameController.text,
          branchId: _selectedBranchId,
          status: _status ? 1 : 0,
        );
        
        // Llamar al servicio para crear el menú
        await _menuService.createMenu(menu);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menú creado exitosamente')),
        );
        
        // Regresar a la pantalla anterior con un resultado positivo
        Navigator.pop(context, true);
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
              // Desplegable para sucursales (en vez de TextFormField)
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
                      onPressed: _createMenu,
                      child: Text('Crear Menú'),
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