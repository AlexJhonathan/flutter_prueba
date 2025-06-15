import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_service.dart';
import 'package:flutter_prueba/pages/admin/supplies/supplies_purchase.dart';

class SuppliesCategoriesList extends StatefulWidget {
  final int branchId;
  final String category;

  const SuppliesCategoriesList({
    Key? key,
    required this.branchId,
    required this.category,
  }) : super(key: key);

  @override
  State<SuppliesCategoriesList> createState() => _SuppliesCategoriesListState();
}

class _SuppliesCategoriesListState extends State<SuppliesCategoriesList> {
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
        builder: (context) => SuppliesPurchase(
          supplyId: supply['id'],
          supplyName: supply['name'],
          unit: supply['unit'],
          branchId: widget.branchId,
        ),
      ),
    );

    if (result == true) {
      _loadSupplies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFED7A9E),
        centerTitle: true,
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
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView.builder(
                        itemCount: _supplies.length,
                        itemBuilder: (context, index) {
                          final supply = _supplies[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 238, 166, 190),
                                  Color.fromARGB(255, 250, 190, 196),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                supply['name'] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'Unidad: ${supply['unit'] ?? 'N/A'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                              onTap: () => _navigateToBuySupplyScreen(supply),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // o reemplaza por otra acción si es necesario
        },
        backgroundColor: const Color.fromARGB(255, 236, 113, 158),
        child: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: 'Volver',
      ),
    );
  }
}
