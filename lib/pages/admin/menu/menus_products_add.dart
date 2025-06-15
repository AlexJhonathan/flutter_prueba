import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/product_service.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/models/product_model.dart';

class MenusProductsAdd extends StatefulWidget {
  final int menuId;

  MenusProductsAdd({required this.menuId});

  @override
  _MenusProductsAddState createState() => _MenusProductsAddState();
}

class _MenusProductsAddState extends State<MenusProductsAdd> {
  final _productService = ProductService();
  final _menuService = MenuListService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<int> _selectedProductIds = [];
  Set<int> _existingProductIds = {};
  bool _isLoading = true;
  String? _error;
  String? _selectedCategory = 'Todas';

  final List<String> _categories = [
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

  Future<void> _fetchExistingMenuProducts() async {
    try {
      final existing = await _menuService.getMenuProducts(widget.menuId, 'Todas');
      _existingProductIds = existing.map((p) => p.productId).toSet();

      final all = await _productService.getProducts(null);
      final available = all.where((p) => !_existingProductIds.contains(p.id)).toList();

      setState(() {
        _products = available;
        _filteredProducts = available;
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
        _filteredProducts =
            _products.where((p) => p.category == category).toList();
      }
    });
  }

  void _toggleSelection(int productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  Future<void> _addSelectedProducts() async {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _menuService.addMenuProducts(widget.menuId, _selectedProductIds);
      Navigator.of(context).pop(true); // Devuelve true para indicar éxito
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar productos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 220, 230),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.only(bottom: 16),
            ),
          ),
          Text(
            'AGREGAR PRODUCTOS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
          ),
          SizedBox(height: 10),
          DropdownButton<String>(
            dropdownColor: Colors.pink[100],
            value: _selectedCategory,
            icon: Icon(Icons.arrow_drop_down, color: Colors.pink[800]),
            underline: Container(),
            onChanged: _filterProducts,
            items: _categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.pink[800])),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        children: [
                          Text(_error!, style: TextStyle(color: Colors.red)),
                          ElevatedButton(
                            onPressed: _fetchExistingMenuProducts,
                            child: Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : _filteredProducts.isEmpty
                      ? Text('No hay productos disponibles en esta categoría')
                      : SizedBox(
                        height: 400, // o MediaQuery.of(context).size.height * 0.5
                        child: ListView.builder(
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final isSelected = _selectedProductIds.contains(product.id);
                            return Container(
                                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
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
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.fastfood, color: Colors.white),
                                  title: Text(product.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    'Precio: ${product.price}\nCategoría: ${product.category}',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleSelection(product.id),
                                    checkColor: Colors.white,
                                    activeColor: Colors.pink[300],
                                  ),
                                ),
                              );
                          },
                        ),
                      ),
  
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 237, 122, 158),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: _selectedProductIds.isEmpty ? null : _addSelectedProducts,
            child: Text('Agregar al menú',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
