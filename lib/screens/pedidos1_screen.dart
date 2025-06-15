import 'package:flutter/material.dart';
import '../models/menu_list_model.dart';
import '../services/menu_list_service.dart';
import '../services/order_service.dart';
import 'lista_menu_productos_screen.dart';
import 'detalle_pedido_screen.dart';

class Pedidos1Screen extends StatefulWidget {
  final String initialSelection; // "Mesa X"
  final int branchId;

  const Pedidos1Screen({
    Key? key,
    required this.initialSelection,
    required this.branchId,
  }) : super(key: key);

  @override
  _Pedidos1ScreenState createState() => _Pedidos1ScreenState();
}

class _Pedidos1ScreenState extends State<Pedidos1Screen> {
  final MenuListService _menuService = MenuListService();
  final OrderService _orderService = OrderService();

  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;
  Menu? _menu; // Almacenar el menú completo
  int? _currentOrderId; // ID del pedido actual
  bool _creatingOrder = false;
  Map<int, Map<String, dynamic>> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    _initializeOrder();
  }

  // Inicializar el pedido y luego cargar las categorías
  Future<void> _initializeOrder() async {
    try {
      setState(() {
        _creatingOrder = true;
        _error = null;
      });

      // Extraer el número de mesa de "Mesa X"
      final tableNumber = int.tryParse(widget.initialSelection.split(' ').last) ?? 1;

      // Crear un nuevo pedido
      final orderResult = await _orderService.createOrder(
        tableId: tableNumber,
        branchId: widget.branchId,
      );

      if (mounted) {
        setState(() {
          _currentOrderId = orderResult['id'];
          _creatingOrder = false;
        });

        // Cargar categorías después de crear el pedido
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

      // Obtener los menús disponibles
      final menus = await _menuService.getMenus();

      // Filtrar el menú correspondiente a la sucursal
      Menu? menu;
      try {
        menu = menus.firstWhere(
          (m) => m.branchId == widget.branchId,
        );
      } catch (e) {
        throw Exception('No se encontró un menú para esta sucursal (${widget.branchId})');
      }

      // Guardar el menú completo
      _menu = menu;

      // Obtener las categorías de los productos del menú
      final products = await _menuService.getMenuProducts(menu.id, 'Todas');

      // Crear un conjunto para evitar categorías duplicadas
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
          // Convertir el conjunto a una lista
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
          builder: (context) => ListaMenuProductosScreen(
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
      appBar: AppBar(
        title: Text('Pedido para: ${widget.initialSelection}'),
        actions: [
          if (_currentOrderId != null)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _navigateToCart,
            ),
        ],
      ),
      body: _buildBody(),
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
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
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
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8),
          ),
          onPressed: () => _navigateToProductsList(category),
          child: Text(
            category,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
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
            builder: (context) => DetallePedidoScreen(
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