import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/services/order_service.dart';
import 'package:flutter_prueba/pages/waitress/order_details.dart';

class OrderProductsList extends StatefulWidget {
  final int menuId;
  final String category;
  final int orderId;
  final Map<int, Map<String, dynamic>> selectedProducts;
  final Function(Map<int, Map<String, dynamic>>) onProductsUpdated;

  const OrderProductsList({
    Key? key,
    required this.menuId,
    required this.category,
    required this.orderId,
    required this.selectedProducts,
    required this.onProductsUpdated,
  }) : super(key: key);

  @override
  _OrderProductsListState createState() => _OrderProductsListState();
}

class _OrderProductsListState extends State<OrderProductsList> {
  final MenuListService _menuService = MenuListService();
  final OrderService _orderService = OrderService();

  List<dynamic> _products = [];
  Map<int, Map<String, dynamic>> _selectedProducts = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProducts = Map.from(widget.selectedProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _menuService.getMenuProducts(widget.menuId, widget.category);

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateProductQuantity(int productId, String productName, double productPrice, int change) {
    setState(() {
      if (!_selectedProducts.containsKey(productId)) {
        if (change > 0) {
          _selectedProducts[productId] = {
            'name': productName,
            'price': productPrice,
            'quantity': change,
            'productId': productId,
          };
        }
      } else {
        int newQuantity = (_selectedProducts[productId]!['quantity'] as int) + change;
        if (newQuantity <= 0) {
          _selectedProducts.remove(productId);
        } else {
          _selectedProducts[productId]!['quantity'] = newQuantity;
        }
      }
    });

    widget.onProductsUpdated(_selectedProducts);
  }

  Future<void> _finalizeOrder() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final totalPrice = _selectedProducts.values.fold<double>(
        0.0,
        (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
      );

      await _orderService.updateOrder(
        orderId: widget.orderId,
        total: totalPrice,
      );

      final details = _selectedProducts.entries.map((entry) {
        return {
          'productId': entry.key,
          'quantity': entry.value['quantity'],
        };
      }).toList();

      await _orderService.addOrderDetails(widget.orderId, details);

      final orderDetails = await _orderService.getOrderById(widget.orderId);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(
              orderId: widget.orderId,
              orderDetails: orderDetails,
              selectedProducts: _selectedProducts.values.toList(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al finalizar el pedido: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuantity = _selectedProducts.values.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    final totalPrice = _selectedProducts.values.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
    );

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
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final Map<String, dynamic>? productData = product.product;
                        if (productData == null) return const SizedBox.shrink();

                        final int productId = productData['id'] ?? 0;
                        final String productName = productData['name'] ?? 'Producto sin nombre';
                        final double productPrice = double.tryParse(productData['price'].toString()) ?? 0.0;

                        final int quantity = _selectedProducts.containsKey(productId)
                            ? _selectedProducts[productId]!['quantity'] as int
                            : 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 238, 166, 190), Color.fromARGB(255, 250, 190, 196)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(productName),
                              subtitle: Text('Precio: \$${productPrice.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.pink),
                                    onPressed: quantity > 0
                                        ? () => _updateProductQuantity(productId, productName, productPrice, -1)
                                        : null,
                                  ),
                                  Text('$quantity'),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.pink),
                                    onPressed: () =>
                                        _updateProductQuantity(productId, productName, productPrice, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: totalQuantity > 0
          ? FloatingActionButton.extended(
              onPressed: _finalizeOrder,
              label: Text('Finalizar \$${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFFED7A9E),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
