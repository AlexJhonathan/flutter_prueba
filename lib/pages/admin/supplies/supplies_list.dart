import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_prueba/services/supply_service.dart';
import 'package:flutter_prueba/models/supply_detail_model.dart';
import 'package:flutter_prueba/pages/admin/supplies/supplies_categories.dart';
import 'package:flutter_prueba/pages/admin/supplies/supplies_register.dart';

class SuppliesList extends StatefulWidget {
  @override
  _SuppliesListState createState() => _SuppliesListState();
}

class _SuppliesListState extends State<SuppliesList> {
  final SupplyService _supplyService = SupplyService();
  List<SupplyDetail> _supplies = [];
  bool _isLoading = false;
  String? _error;

  String? _selectedBranchId;
  String? _selectedSupplyId;
  DateTime? _selectedDate;

  final Map<String, String> _branchOptions = {
    '3': 'Tarija Principal',
    '5': 'La Paz Principal',
    '6': 'La Paz Mega',
    '4': 'Carla Tarija Parque',
  };

  final List<String> _supplyOptions = ['1', '2', '3', '4', '5'];

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
      backgroundColor: const Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 113, 158),
        title: const Text('Lista de Insumos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedBranchId,
              decoration: InputDecoration(
                labelText: 'Sucursal',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

            DropdownButtonFormField<String>(
              value: _selectedSupplyId,
              decoration: InputDecoration(
                labelText: 'Supply ID (opcional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Fecha: No seleccionada'
                        : 'Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 113, 158),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Seleccionar Fecha', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _fetchSupplies,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 236, 113, 158),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buscar Insumos', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _supplies.isEmpty
                      ? const Center(child: Text('No se encontraron insumos.'))
                      : ListView.builder(
                          itemCount: _supplies.length,
                          itemBuilder: (context, index) {
                            final supplyDetail = _supplies[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(supplyDetail.supply.name,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Unidad: ${supplyDetail.supply.unit}'),
                                    Text('Categoría: ${supplyDetail.supply.category}'),
                                    Text('Comprado: ${supplyDetail.purchased}'),
                                    Text('Consumido: ${supplyDetail.consumed}'),
                                    Text('Restante: ${supplyDetail.remaining}'),
                                    Text('Creado: ${supplyDetail.createdAt}'),
                                    Text('Actualizado: ${supplyDetail.updatedAt}'),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SuppliesCategories(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(255, 236, 113, 158),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text('Añadir Compra', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
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
                  MaterialPageRoute(builder: (context) => SuppliesCategories()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 236, 113, 158),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ir a Añadir Compra', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuppliesRegister()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 236, 113, 158),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Registrar Insumo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
