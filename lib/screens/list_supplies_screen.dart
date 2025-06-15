import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para manejar el formato de fechas
import '../services/supply_service.dart';
import '../models/supply_detail_model.dart';
import 'add_purchase_screen.dart'; // Importar la pantalla de añadir compra
import 'registrar_insumo_screen.dart'; // Importar la pantalla de registrar insumo

class ListSuppliesScreen extends StatefulWidget {
  @override
  _ListSuppliesScreenState createState() => _ListSuppliesScreenState();
}

class _ListSuppliesScreenState extends State<ListSuppliesScreen> {
  final SupplyService _supplyService = SupplyService();
  List<SupplyDetail> _supplies = [];
  bool _isLoading = false;
  String? _error;

  // Variables para las listas desplegables
  String? _selectedBranchId;
  String? _selectedSupplyId;
  DateTime? _selectedDate;

  // Opciones para las listas desplegables
  final Map<String, String> _branchOptions = {
    '3': 'Tarija Principal',
    '5': 'La Paz Principal',
    '6': 'La Paz Mega',
    '4': 'Carla Tarija Parque',
  };

  final List<String> _supplyOptions = ['1', '2', '3', '4', '5']; // Opciones de ejemplo

  Future<void> _fetchSupplies() async {
    if (_selectedBranchId == null) {
      setState(() {
        _error = 'El campo Sucursal es obligatorio.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final branchId = int.parse(_selectedBranchId!);
      final supplyId = _selectedSupplyId != null ? int.parse(_selectedSupplyId!) : null;

      final supplies = await _supplyService.getSupplyDetails(
        branchId: branchId,
        supplyId: supplyId,
        date: _selectedDate,
      );

      setState(() {
        _supplies = supplies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Insumos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Lista desplegable para Branch ID
            DropdownButtonFormField<String>(
              value: _selectedBranchId,
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                border: OutlineInputBorder(),
              ),
              items: _branchOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBranchId = newValue;
                });
              },
            ),
            const SizedBox(height: 16),

            // Lista desplegable para Supply ID
            DropdownButtonFormField<String>(
              value: _selectedSupplyId,
              decoration: const InputDecoration(
                labelText: 'Supply ID (opcional)',
                border: OutlineInputBorder(),
              ),
              items: _supplyOptions.map((String supply) {
                return DropdownMenuItem<String>(
                  value: supply,
                  child: Text('Supply $supply'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSupplyId = newValue;
                });
              },
            ),
            const SizedBox(height: 16),

            // Selector de Fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Fecha: No seleccionada'
                        : 'Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón para buscar insumos
            ElevatedButton(
              onPressed: _fetchSupplies,
              child: const Text('Buscar Insumos'),
            ),
            const SizedBox(height: 16),

            // Mostrar error si existe
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),

            // Mostrar lista de insumos
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _supplies.isEmpty
                      ? const Center(child: Text('No se encontraron insumos.'))
                      : ListView.builder(
                          itemCount: _supplies.length,
                          itemBuilder: (context, index) {
                            final supplyDetail = _supplies[index];
                            return ListTile(
                              title: Text(supplyDetail.supply.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Unidad: ${supplyDetail.supply.unit}'),
                                  Text('Categoría: ${supplyDetail.supply.category}'),
                                  Text('Comprado: ${supplyDetail.purchased}'),
                                  Text('Consumido: ${supplyDetail.consumed}'),
                                  Text('Restante: ${supplyDetail.remaining}'),
                                  Text('Creado: ${supplyDetail.createdAt}'),
                                  Text('Actualizado: ${supplyDetail.updatedAt}'),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPurchaseScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Añadir Compra'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPurchaseScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Ir a Añadir Compra'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrarInsumoScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Registrar Insumo'),
            ),
          ],
        ),
      ),
    );
  }
}