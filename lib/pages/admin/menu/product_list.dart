import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/product_service.dart';
import 'package:flutter_prueba/models/product_model.dart';
import 'package:flutter_prueba/pages/admin/menu/product_add.dart';
import 'package:flutter_prueba/pages/admin/menu/product_edit.dart';

import 'package:intl/intl.dart';

class ProductList extends StatefulWidget {
  final int? menuId;

  ProductList({this.menuId});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
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

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    if (dateTime is String) {
      try {
        dateTime = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime;
      }
    }

    if (dateTime is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }

    return dateTime.toString();
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'Todas';
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

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      setState(() {
        _selectedCategory = newCategory;
      });
      _filterProducts(newCategory);
    }
  }

  void _filterProducts(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null || category == 'Todas') {
        _filteredProducts = _products;
      } else {
        _filteredProducts =
            _products.where((product) => product.category == category).toList();
      }
    });
  }

  void _editProduct(Product product) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ProductEdit(product: product)
    );

    if (result == true) {
      _fetchProducts(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 237, 122, 158),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 40,
                    child: Text("PRODUCTOS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                  ), 
                ),
              ),

            Container(
              height: 40,
              width: 300, // Altura fija deseada
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 236, 113, 158), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Colors.pink[100],
                  value: _selectedCategory,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.pink[800]),
                  onChanged: _onCategoryChanged,
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.pink[800])),
                    );
                  }).toList(),
                ),
              ),
            ),


            SizedBox(height: 10),
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
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 238, 166, 190),
                                        Color.fromARGB(255, 250, 190, 196)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    title: Text(
                                      product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Precio: ${product.price}', style: TextStyle(color: Colors.white)),
                                        Text('Categoría: ${product.category}', style: TextStyle(color: Colors.white)),
                                        Text(
                                          'Estado: ${product.status == 1 ? "Activo" : "Inactivo"}',
                                          style: TextStyle(
                                            color: product.status == 1 ? Colors.lightGreenAccent : Colors.redAccent,
                                          ),
                                        ),
                                        Text('Creado: ${_formatDateTime(product.createdAt)}',
                                            style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Color.fromARGB(255, 236, 113, 158),
                                      onPressed: () => _editProduct(product),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 236, 113, 158),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (_) => ProductAdd(),
          );

          if (result == true) {
            await _fetchProducts(); // ← Esto actualizará la lista correctamente
          }
        }
      ),
    );
  }
}
