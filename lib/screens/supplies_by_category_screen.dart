import 'package:flutter/material.dart';
import '../services/supply_service.dart';
import 'buy_supply_screen.dart';

class SuppliesByCategoryScreen extends StatefulWidget {
  final int branchId;
  final String category;

  const SuppliesByCategoryScreen({
    Key? key,
    required this.branchId,
    required this.category,
  }) : super(key: key);

  @override
  State<SuppliesByCategoryScreen> createState() => _SuppliesByCategoryScreenState();
}

class _SuppliesByCategoryScreenState extends State<SuppliesByCategoryScreen> {
  final SupplyService _supplyService = SupplyService();
  List<Map<String, dynamic>> _supplies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSupplies();
  }

  Future<void> _loadSupplies() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Asumiendo que obtenerInsumosPorCategoria está implementado en SupplyService
      final supplies = await _supplyService.obtenerInsumosPorCategoria(widget.branchId, widget.category);
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

  void _navigateToBuySupplyScreen(Map<String, dynamic> supply) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuySupplyScreen(
          supplyId: supply['id'], // ID del insumo
          supplyName: supply['name'], // Nombre del insumo
          unit: supply['unit'], // Unidad del insumo
          branchId: widget.branchId, // Pasar el ID de la sucursal
        ),
      ),
    );

    // Si el resultado es true, recargar los insumos para reflejar cambios
    if (result == true) {
      _loadSupplies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insumos - ${widget.category}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSupplies,
                        child: const Text('Intentar de nuevo'),
                      ),
                    ],
                  ),
                )
              : _supplies.isEmpty
                  ? const Center(child: Text('No hay insumos disponibles en esta categoría'))
                  : ListView.builder(
                      itemCount: _supplies.length,
                      itemBuilder: (context, index) {
                        final supply = _supplies[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(supply['name'] ?? 'Sin nombre'),
                            subtitle: Text('Unidad: ${supply['unit'] ?? 'N/A'}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _navigateToBuySupplyScreen(supply),
                          ),
                        );
                      },
                    ),
    );
  }
}