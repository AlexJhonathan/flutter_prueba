import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/services/product_service.dart';
import 'package:flutter_prueba/models/product_model.dart';

class ManageProductsList extends StatefulWidget {
  final int menuId;
  final String category;

  const ManageProductsList({
    Key? key,
    required this.menuId,
    required this.category,
  }) : super(key: key);

  @override
  _ManageProductsListState createState() => _ManageProductsListState();
}

class _ManageProductsListState extends State<ManageProductsList> {
  final MenuListService _menuService = MenuListService();
  final ProductService _productService = ProductService();
  List<dynamic> _products = []; // Keep as dynamic until we understand the exact structure
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Obtener los productos de la categoría seleccionada
      final products = await _menuService.getMenuProducts(widget.menuId, widget.category);
      
      // Print some debug info
      if (products.isNotEmpty) {
        print('First product type: ${products.first.runtimeType}');
        print('First product content: ${products.first}');
      }
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProductStatus(int productId, int newStatus) async {
    try {
      final product = Product(
        id: productId,
        name: '', // These fields aren't needed for the update
        price: 0, 
        category: '',
        status: newStatus, // This is what we're updating
      );

      await _productService.updateProduct(product);

      // Update the product in the UI
      setState(() {
        for (int i = 0; i < _products.length; i++) {
          // Access the product data correctly based on the structure
          final menuProduct = _products[i];
          final productData = menuProduct.product; // Assuming this is how to access the product data
          
          if (productData != null && productData['id'] == productId) {
            // Update the status in our local data
            productData['status'] = newStatus;
            break;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado del producto actualizado')),
      );
    } catch (e) {
      print('Error al actualizar el estado del producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el estado del producto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: const Color(0xFFED7A9E),
        elevation: 0,
        title: Text(
          'Productos: ${widget.category}',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.pink))
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : _products.isEmpty
                      ? const Center(child: Text('No hay productos disponibles'))
                      : _buildProductsList(),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.pink)),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final menuProduct = _products[index];

        // Acceder a los datos del producto
        final productData = menuProduct.product;
        if (productData == null) {
          print('Product data is null for index $index');
          return const SizedBox.shrink();
        }

        // Obtener detalles del producto
        final int productId = productData['id'] ?? 0;
        final String productName = productData['name'] ?? 'Producto sin nombre';
        final double productPrice = double.tryParse(productData['price'].toString()) ?? 0.0;
        final bool isAvailable = productData['status'] == 1;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 238, 166, 190),
                  Color.fromARGB(255, 250, 190, 196)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                productName,
                style: TextStyle(
                  color: isAvailable ? Colors.black : Colors.grey,
                  fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                'Precio: \$${productPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isAvailable ? Colors.black : Colors.grey,
                ),
              ),
              trailing: Switch(
                value: isAvailable,
                activeColor: Colors.pink,
                onChanged: (value) {
                  final newStatus = value ? 1 : 2;
                  _updateProductStatus(productId, newStatus);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}