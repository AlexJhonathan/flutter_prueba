import 'package:flutter/material.dart';
import '../services/menu_list_service.dart';
import '../services/order_service.dart';
import 'detalle_pedido_screen.dart';

class ListaMenuProductosScreen extends StatefulWidget {
  final int menuId;
  final String category;
  final int orderId;
  final Map<int, Map<String, dynamic>> selectedProducts;
  final Function(Map<int, Map<String, dynamic>>) onProductsUpdated;

  const ListaMenuProductosScreen({
    Key? key,
    required this.menuId,
    required this.category,
    required this.orderId,
    required this.selectedProducts,
    required this.onProductsUpdated,
  }) : super(key: key);

  @override
  _ListaMenuProductosScreenState createState() => _ListaMenuProductosScreenState();
}

class _ListaMenuProductosScreenState extends State<ListaMenuProductosScreen> {
  final MenuListService _menuService = MenuListService();
  final OrderService _orderService = OrderService();

  List<dynamic> _products = [];
  Map<int, Map<String, dynamic>> _selectedProducts = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProducts = Map.from(widget.selectedProducts); // Copiar productos seleccionados
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

    // Actualizar el estado global
    widget.onProductsUpdated(_selectedProducts);
  }

  // Método modificado con manejo de errores mejorado
  Future<void> _finalizeOrder() async {
  try {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Calcular el total primero
    final totalPrice = _selectedProducts.values.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
    );

    // Actualizar el total en la orden principal
    await _orderService.updateOrder(
      orderId: widget.orderId,
      total: totalPrice,
    );

    // Preparar los detalles de los productos
    final List<Map<String, dynamic>> details = _selectedProducts.entries.map((entry) {
      return {
        'productId': entry.key,
        'quantity': entry.value['quantity'],
      };
    }).toList();

    // Enviar los detalles de los productos a la API
    await _orderService.addOrderDetails(widget.orderId, details);

    // Obtener los detalles actualizados del pedido
    final orderDetails = await _orderService.getOrderById(widget.orderId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Navegar a la pantalla de detalle
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetallePedidoScreen(
            orderId: widget.orderId,
            orderDetails: orderDetails,
            selectedProducts: _selectedProducts.values.toList(),
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar el pedido: $_error')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos: ${widget.category}'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _isLoading
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
                        : _buildProductsList(),
              ),
              _buildBottomBar(),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
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
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(productName),
            subtitle: Text('Precio: \$${productPrice.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: quantity > 0
                      ? () => _updateProductQuantity(productId, productName, productPrice, -1)
                      : null,
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateProductQuantity(productId, productName, productPrice, 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final totalQuantity = _selectedProducts.values.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    final totalPrice = _selectedProducts.values.fold<double>(
      0.0,
      (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int),
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos: $totalQuantity',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: totalQuantity > 0 ? _finalizeOrder : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar Pedido', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}