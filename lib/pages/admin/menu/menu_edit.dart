import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_create_service.dart';
import 'package:flutter_prueba/models/menu_list_model.dart';

class MenuEdit extends StatefulWidget {
  final Menu menu;

  const MenuEdit({Key? key, required this.menu}) : super(key: key);

  @override
  State<MenuEdit> createState() => _MenuEditState();
}

class _MenuEditState extends State<MenuEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late int _selectedBranchId;
  bool _status = false;
  bool _isLoading = false;
  final _menuService = MenuCreateService();

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

    if (_branchOptions.containsKey(widget.menu.branchId)) {
      _selectedBranchId = widget.menu.branchId;
    } else {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 220, 230),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado rosa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 236, 113, 158),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: const [
                  Text(
                    "Editar Menú",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Nombre del Menú',
                          hintStyle: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w200, color: Colors.black),
                          contentPadding: EdgeInsets.only(bottom: -10),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField<int>(
                        value: _selectedBranchId,
                        decoration: const InputDecoration(
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
                      title: const Text('Estado'),
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
              padding: const EdgeInsets.only(bottom: 16, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 236, 113, 158),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Guardar", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
