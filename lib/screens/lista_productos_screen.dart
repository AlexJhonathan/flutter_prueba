import 'package:flutter/material.dart';
import '../services/menu_list_service.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
//import '../models/menu_list_model.dart'; // Make sure this is imported

class ListaProductosScreen extends StatefulWidget {
  final int menuId;
  final String category;

  const ListaProductosScreen({
    Key? key,
    required this.menuId,
    required this.category,
  }) : super(key: key);

  @override
  _ListaProductosScreenState createState() => _ListaProductosScreenState();
}

class _ListaProductosScreenState extends State<ListaProductosScreen> {
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
            // Note: This approach might need adjustment based on your actual MenuProduct class structure
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
      appBar: AppBar(
        title: Text('Productos: ${widget.category}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? const Center(child: Text('No hay productos disponibles'))
                  : _buildProductsList(),
    );
  }
Widget _buildProductsList() {
  return ListView.builder(
    itemCount: _products.length,
    itemBuilder: (context, index) {
      final menuProduct = _products[index];

      // Acceder a los datos del producto
      final productData = menuProduct.product; // Asegúrate de que esta sea la forma correcta de acceder
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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListTile(
          title: Text(
            productName,
            style: TextStyle(
              color: isAvailable ? Colors.black : Colors.grey, // Cambiar el color si no está disponible
              fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            'Precio: \$${productPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: isAvailable ? Colors.black : Colors.grey, // Cambiar el color si no está disponible
            ),
          ),
          trailing: Switch(
            value: isAvailable,
            onChanged: (value) {
              final newStatus = value ? 1 : 2;
              _updateProductStatus(productId, newStatus);
            },
          ),
        ),
      );
    },
  );
}
  
}