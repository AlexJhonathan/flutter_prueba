import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/models/menu_list_model.dart';
import 'package:flutter_prueba/pages/cook/manage_products_list.dart';

class ManageProducts extends StatefulWidget {
  final int branchId;

  const ManageProducts({
    Key? key, 
    required this.branchId
  }) : super(key: key);

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  final MenuListService _menuService = MenuListService();
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;
  Menu? _selectedMenu;

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
        builder: (context) => ManageProductsList(
          menuId: _selectedMenu!.id,
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 122, 158),
        title: const Text(
          'Administrar Productos',
          style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: _buildBody(),
      ),
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
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
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
}