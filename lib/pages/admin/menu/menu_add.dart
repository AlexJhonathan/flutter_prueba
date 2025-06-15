import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_create_service.dart';
import 'package:flutter_prueba/models/menu_create_model.dart';

class MenuAdd extends StatefulWidget {
  @override
  _MenuAddState createState() => _MenuAddState();
}

class _MenuAddState extends State<MenuAdd> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late int _selectedBranchId;
  bool _status = false;
  final _menuService = MenuCreateService();
  bool _isLoading = false;

  final Map<int, String> _branchOptions = {
    3: 'Tarija Principal',
    4: 'Tarija Parque',
    5: 'La Paz Principal',
    6: 'La Paz Mega',
  };

  @override
  void initState() {
    super.initState();
    _selectedBranchId = _branchOptions.keys.first;
  }

  Future<void> _createMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final menu = MenuCreate(
          name: _nameController.text,
          branchId: _selectedBranchId,
          status: _status ? 1 : 0,
        );
        await _menuService.createMenu(menu);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 220, 230),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado rosa
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 236, 113, 158),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Crear Menú",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nombre del Menú',
                          hintStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w200, color: Colors.black),
                          contentPadding: EdgeInsets.only(bottom: -10),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                        ),
                        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField<int>(
                        value: _selectedBranchId,
                        decoration: InputDecoration(
                          hintText: 'Sucursal',
                          contentPadding: EdgeInsets.only(bottom: -10),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                        ),
                        items: _branchOptions.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedBranchId = value!),
                        validator: (value) => value == null ? 'Seleccione una sucursal' : null,
                      ),
                    ),
                    SwitchListTile(
                      title: Text('Estado'),
                      subtitle: Text(_status ? 'Activo' : 'Inactivo'),
                      value: _status,
                      activeColor: Colors.green,
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 16, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _createMenu(),
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 236, 113, 158)),
                    child: _isLoading
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
