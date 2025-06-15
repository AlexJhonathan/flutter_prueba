import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'package:intl/intl.dart'; // Importar para formateo de fechas

class ListProductsScreen extends StatefulWidget {
  final int? menuId;

  ListProductsScreen({this.menuId});

  @override
  _ListProductsScreenState createState() => _ListProductsScreenState();
}

class _ListProductsScreenState extends State<ListProductsScreen> {
  final _productService = ProductService();
  bool _isLoading = true;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
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

  // Función para formatear fechas
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';
    
    // Si es string, convertir a DateTime
    if (dateTime is String) {
      try {
        dateTime = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime; // Si no se puede parsear, mostrar el string original
      }
    }
    
    // Formatear la fecha y hora (sin segundos)
    if (dateTime is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
    
    return dateTime.toString();
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _productService.getProducts(widget.menuId);
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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

  Future<void> _deleteProduct(int productId) async {
    try {
      await _productService.deleteProduct(productId);
      setState(() {
        _products.removeWhere((product) => product.id == productId);
        _filteredProducts.removeWhere((product) => product.id == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $e')),
      );
    }
  }

  void _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (result == true) {
      // Recargar la lista de productos
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              ).then((value) {
                if (value == true) {
                  _fetchProducts(); // Actualizar después de añadir
                }
              });
            },
          ),
        ],
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
                        ? Center(child: Text('No hay productos en esta categoría'))
                        : ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    product.name,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ID eliminado
                                      Text('Precio: ${product.price}'),
                                      Text('Categoría: ${product.category}'),
                                      Text(
                                        'Estado: ${product.status == 1 ? "Activo" : "Inactivo"}',
                                        style: TextStyle(
                                          color: product.status == 1 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      // Fechas formateadas
                                      Text('Creado: ${_formatDateTime(product.createdAt)}'),
                                      Text('Actualizado: ${_formatDateTime(product.updatedAt)}'),
                                      if (product.deletedAt != null) 
                                        Text(
                                          'Eliminado: ${_formatDateTime(product.deletedAt)}',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editProduct(product),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteProduct(product.id),
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
    );
  }
}