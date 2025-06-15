import 'package:flutter/material.dart';
import '../services/menu_list_service.dart';
import '../models/menu_list_model.dart';  // Make sure to import this
import 'lista_productos_screen.dart';  // Import the product list screen

class AdministrarProductosScreen extends StatefulWidget {
  final int branchId;  // Add parameter for branch ID

  const AdministrarProductosScreen({
    Key? key, 
    required this.branchId  // Make it required
  }) : super(key: key);

  @override
  _AdministrarProductosScreenState createState() => _AdministrarProductosScreenState();
}

class _AdministrarProductosScreenState extends State<AdministrarProductosScreen> {
  final MenuListService _menuService = MenuListService();
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;
  Menu? _selectedMenu;  // Store the selected menu

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Obtener los menús disponibles
      final menus = await _menuService.getMenus();
      print('Menús obtenidos: ${menus.length}');

      if (menus.isEmpty) {
        throw Exception('No hay menús disponibles');
      }

      // Filtrar el menú correspondiente a la sucursal
      Menu? menu;
      try {
        menu = menus.firstWhere(
          (m) => m.branchId == widget.branchId,
        );
      } catch (e) {
        throw Exception('No se encontró un menú para esta sucursal (${widget.branchId})');
      }
      
      // Guardar el menú seleccionado
      _selectedMenu = menu;
      print('Menú seleccionado: ${menu.id}');

      // Obtener los productos del menú seleccionado
      final products = await _menuService.getMenuProducts(menu.id, 'Todas');
      print('Productos obtenidos: ${products.length}');

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
          _categories = categorySet.toList();
          _isLoading = false;
        });
        print('Categorías cargadas: $_categories');
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

 void _navigateToProductsList(String category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ListaProductosScreen(
        menuId: _selectedMenu!.id,
        category: category,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
}