import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/menu_list_service.dart';
import '../models/product_model.dart';
//import '../models/menu_list_model.dart';

class AddMenuProductsScreen extends StatefulWidget {
  final int menuId;

  AddMenuProductsScreen({required this.menuId});

  @override
  _AddMenuProductsScreenState createState() => _AddMenuProductsScreenState();
}

class _AddMenuProductsScreenState extends State<AddMenuProductsScreen> {
  final _productService = ProductService();
  final _menuService = MenuListService();
  bool _isLoading = true;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Set<int> _existingProductIds = {}; // Set para almacenar IDs de productos existentes
  List<int> _selectedProductIds = [];
  String _error = '';
  String? _selectedCategory;

  List<String> _categories = [
    'Todas',
    'Desayunos',
    'Tortas (porciones)',
    'Tortas enteras',
    'Minicakes',
    'Para compartir',
    'Bebidas',
    'Frappé',
    'Bagel',
    'Paninis',
    'Chesscakes (porcion)',
    'Chesscakes enteros',
    'Ensaladas',
    'Cuchareables',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExistingMenuProducts();
  }

  // Paso 1: Obtener productos existentes en el menú
  Future<void> _fetchExistingMenuProducts() async {
    try {
      // Obtener productos que ya están en el menú
      final existingProducts = await _menuService.getMenuProducts(widget.menuId, 'Todas');
      
      // Crear un conjunto de IDs de productos existentes
      setState(() {
        _existingProductIds = existingProducts.map((p) => p.productId).toSet();
      });
      
      // Ahora obtenemos todos los productos disponibles
      _fetchProducts();
    } catch (e) {
      setState(() {
        _error = 'Error al cargar productos existentes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _productService.getProducts(null); // Obtener todos los productos
      
      // Filtrar los productos existentes
      final availableProducts = products.where((product) => 
        !_existingProductIds.contains(product.id)
      ).toList();
      
      setState(() {
        _products = availableProducts;
        _filteredProducts = availableProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar productos: $e';
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null || category == 'Todas') {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) => product.category == category).toList();
      }
    });
  }

  void _toggleProductSelection(int productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  Future<void> _saveMenuProducts() async {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Intentar añadir los productos al menú
      await _menuService.addMenuProducts(widget.menuId, _selectedProductIds);
      
      // Si llegamos aquí, todo salió bien
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Productos añadidos exitosamente')),
      );
      
      // Navegar a la pantalla anterior con un resultado positivo
      Navigator.of(context).pop(true);
    } catch (e) {
      // Si hay un error, mostrar el mensaje
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir productos: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Productos al Menú'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Categoría',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                _filterProducts(newValue);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : _filteredProducts.isEmpty
                        ? Center(child: Text('No hay productos disponibles para añadir a este menú'))
                        : ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              final isSelected = _selectedProductIds.contains(product.id);
                              return ListTile(
                                title: Text(product.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Precio: ${product.price}'),
                                    Text('Categoría: ${product.category}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                                  onPressed: () => _toggleProductSelection(product.id),
                                ),
                                onTap: () => _toggleProductSelection(product.id),
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveMenuProducts,
              child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Guardar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}