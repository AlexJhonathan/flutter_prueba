import 'package:flutter/material.dart';
import 'package:flutter_prueba/models/menu_list_model.dart';
import 'package:flutter_prueba/pages/waitress/order_products_list.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/services/order_service.dart';
import 'package:flutter_prueba/pages/waitress/order_details.dart';

class NewOrder extends StatefulWidget {
  final String initialSelection; // "Mesa X"
  final int branchId;

  const NewOrder({
    Key? key,
    required this.initialSelection,
    required this.branchId,
  }) : super(key: key);

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final MenuListService _menuService = MenuListService();
  final OrderService _orderService = OrderService();

  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;
  Menu? _menu;
  int? _currentOrderId;
  bool _creatingOrder = false;
  Map<int, Map<String, dynamic>> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  Future<void> _initializeOrder() async {
    try {
      setState(() {
        _creatingOrder = true;
        _error = null;
      });

      final tableNumber = int.tryParse(widget.initialSelection.split(' ').last) ?? 1;

      final orderResult = await _orderService.createOrder(
        tableId: tableNumber,
        branchId: widget.branchId,
      );

      if (mounted) {
        setState(() {
          _currentOrderId = orderResult['id'];
          _creatingOrder = false;
        });

        await _loadCategories();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al crear el pedido: $e';
          _creatingOrder = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final menus = await _menuService.getMenus();

      Menu? menu;
      try {
        menu = menus.firstWhere(
          (m) => m.branchId == widget.branchId,
        );
      } catch (e) {
        throw Exception('No se encontró un menú para esta sucursal (${widget.branchId})');
      }

      _menu = menu;
      final products = await _menuService.getMenuProducts(menu.id, 'Todas');

      final categorySet = <String>{};

      for (var product in products) {
        if (product.product != null &&
            product.product!['category'] != null &&
            product.product!['category'].toString().trim().isNotEmpty) {
          categorySet.add(product.product!['category'].toString());
        }
      }

      if (mounted) {
        setState(() {
          _categories = categorySet.toList();
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

  void _navigateToProductsList(String category) {
    if (_menu != null && _currentOrderId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderProductsList(
            menuId: _menu!.id,
            category: category,
            orderId: _currentOrderId!,
            selectedProducts: _selectedProducts,
            onProductsUpdated: _updateSelectedProducts,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo encontrar el menú o el pedido')),
      );
    }
  }

  void _updateSelectedProducts(Map<int, Map<String, dynamic>> products) {
    setState(() {
      _selectedProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 122, 158),
        title: Text(
          'Pedido para: ${widget.initialSelection}',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: _buildBody(),
      ),

      floatingActionButton: _currentOrderId != null
    ? FloatingActionButton(
        onPressed: _navigateToCart,
        backgroundColor: const Color.fromARGB(255, 237, 122, 158),
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      )
    : null,
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
    
  }

  Widget _buildBody() {
    if (_creatingOrder) {
      return _buildLoadingState('Creando pedido...');
    }

    if (_isLoading) {
      return _buildLoadingState('Cargando categorías...');
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('No hay categorías disponibles'));
    }

    return _buildCategoriesGrid();
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.pink),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategories,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 237, 122, 158),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return GestureDetector(
          onTap: () => _navigateToProductsList(category),
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
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCart() {
    if (_currentOrderId != null) {
      _orderService.getOrderById(_currentOrderId!).then((orderDetails) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(
              orderId: _currentOrderId!,
              orderDetails: orderDetails,
              selectedProducts: _selectedProducts.values.toList(),
            ),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener los detalles del pedido: $error')),
        );
      });
    }
  }
}
