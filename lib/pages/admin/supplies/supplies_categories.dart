import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_category_service.dart';
import 'package:flutter_prueba/pages/admin/supplies/supplies_categories_list.dart';

class SuppliesCategories extends StatefulWidget {
  const SuppliesCategories({Key? key}) : super(key: key);

  @override
  State<SuppliesCategories> createState() => _SuppliesCategoriesState();
}

class _SuppliesCategoriesState extends State<SuppliesCategories> {
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
        builder: (context) => SuppliesCategoriesList(
          branchId: int.parse(_selectedBranchId!),
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFED7A9E),
        title: const Text(
          'COMPRA DE INSUMOS',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: DropdownButtonFormField<String>(
              value: _selectedBranchId,
              decoration: InputDecoration(
                labelText: 'Seleccionar Sucursal',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: '3', child: Text('Tarija Principal')),
                DropdownMenuItem(value: '4', child: Text('Tarija Parque')),
                DropdownMenuItem(value: '5', child: Text('La Paz')),
                DropdownMenuItem(value: '6', child: Text('La Paz Mega')),
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

          if (_selectedBranchId != null)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categorías de Insumos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFED7A9E),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Intentar de nuevo'),
                            ),
                          ],
                        ),
                      )
                    : _categories.isEmpty
                        ? const Center(child: Text('No hay categorías disponibles'))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.builder(
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
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
                                    leading: const Icon(Icons.category, color: Colors.white),
                                    title: Text(
                                      _categories[index],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                    onTap: () => _navigateToSuppliesByCategory(_categories[index]),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
