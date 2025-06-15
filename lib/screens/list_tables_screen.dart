import 'package:flutter/material.dart';
import '../services/table_service.dart';

class ListTablesScreen extends StatefulWidget {
  final int branchId;

  ListTablesScreen({required this.branchId});

  @override
  _ListTablesScreenState createState() => _ListTablesScreenState();
}

class _ListTablesScreenState extends State<ListTablesScreen> {
  final TableService _tableService = TableService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tables = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    try {
      final tables = await _tableService.getTablesByBranch(widget.branchId);
      setState(() {
        _tables = tables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las mesas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _changeTableStatus(int tableId, bool currentStatus) async {
    try {
      final newStatus = !currentStatus; // Cambiar el estado al opuesto
      await _tableService.updateTableStatus(tableId, newStatus);
      _fetchTables(); // Refrescar la lista de mesas después de cambiar el estado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado de la mesa actualizado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar el estado de la mesa: $e')),
      );
    }
  }

  Future<void> _deleteTable(int tableId) async {
    try {
      await _tableService.deleteTable(tableId);
      _fetchTables(); // Refrescar la lista de mesas después de eliminar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la mesa: $e')),
      );
    }
  }

  Future<void> _addTable() async {
    final TextEditingController numberController = TextEditingController();
    bool isActive = true;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir Nueva Mesa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Mesa',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Estado:'),
                  Switch(
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                  ),
                  Text(isActive ? 'Activo' : 'Inactivo'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final number = int.tryParse(numberController.text);
                if (number == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, ingrese un número válido')),
                  );
                  return;
                }

                try {
                  await _tableService.addTable(widget.branchId, number, isActive);
                  Navigator.pop(context);
                  _fetchTables(); // Refrescar la lista de mesas
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mesa añadida correctamente')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al añadir la mesa: $e')),
                  );
                }
              },
              child: Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesas de la Sucursal'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: _tables.length,
                  itemBuilder: (context, index) {
                    final table = _tables[index];
                    return ListTile(
                      title: Text('Mesa ${table['number']}'), // Mostrar el número de la mesa
                      subtitle: Text('Estado: ${table['status'] ? "Activo" : "Inactivo"}'), // Mostrar el estado
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              table['status'] ? Icons.toggle_on : Icons.toggle_off,
                              color: table['status'] ? Colors.green : Colors.grey,
                            ),
                            onPressed: () {
                              _changeTableStatus(table['id'], table['status']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteTable(table['id']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTable,
        child: Icon(Icons.add),
        tooltip: 'Añadir Mesa',
      ),
    );
  }
}