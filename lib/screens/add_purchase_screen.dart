import 'package:flutter/material.dart';
import '../services/supply_category_service.dart';
import 'supplies_by_category_screen.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final SupplyCategoryService _categoryService = SupplyCategoryService();
  String? _selectedBranchId;
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _loadCategories() async {
    if (_selectedBranchId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Utilizando el método existente obtenerCategorias() en lugar de obtenerCategoriasPorSucursal
      final categories = await _categoryService.obtenerCategorias();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToSuppliesByCategory(String category) {
    if (_selectedBranchId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuppliesByCategoryScreen(
          branchId: int.parse(_selectedBranchId!),
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra de Insumos'),
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar la sucursal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedBranchId,
              decoration: const InputDecoration(
                labelText: 'Seleccionar Sucursal',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: '3',
                  child: Text('Tarija Principal'),
                ),
                DropdownMenuItem(
                  value: '4',
                  child: Text('Tarija Parque'),
                ),
                DropdownMenuItem(
                  value: '5',
                  child: Text('La Paz'),
                ),
                DropdownMenuItem(
                  value: '6',
                  child: Text('La Paz Mega'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBranchId = newValue;
                  _categories = [];
                });
                _loadCategories();
              },
            ),
          ),
          
          // Sección de título para categorías
          if (_selectedBranchId != null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categorías de Insumos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
          // Mostrar categorías o estado de carga
          Expanded(
            child: _isLoading
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
                              onPressed: _loadCategories,
                              child: const Text('Intentar de nuevo'),
                            ),
                          ],
                        ),
                      )
                    : _selectedBranchId == null
                        ? const Center(child: Text('Seleccione una sucursal para ver las categorías'))
                        : _categories.isEmpty
                            ? const Center(child: Text('No hay categorías disponibles'))
                            : ListView.builder(
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        _categories[index],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: const Icon(Icons.arrow_forward_ios),
                                      onTap: () => _navigateToSuppliesByCategory(_categories[index]),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}