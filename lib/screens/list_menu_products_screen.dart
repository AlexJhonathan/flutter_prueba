import 'package:flutter/material.dart';
import '../services/menu_list_service.dart';
import '../models/menu_list_model.dart';

class ListMenuProductsScreen extends StatefulWidget {
  final int menuId;

  ListMenuProductsScreen({required this.menuId});

  @override
  _ListMenuProductsScreenState createState() => _ListMenuProductsScreenState();
}

class _ListMenuProductsScreenState extends State<ListMenuProductsScreen> {
  final MenuListService _menuService = MenuListService();
  List<MenuProduct> _products = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'Todas'; // Categoría por defecto
  bool _isDeletingProduct = false;

  @override
  void initState() {
    super.initState();
    _loadMenuProducts();
  }

  Future<void> _loadMenuProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _menuService.getMenuProducts(widget.menuId, _selectedCategory);
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

  void _onCategoryChanged(String? newCategory) {
    if (newCategory != null) {
      setState(() {
        _selectedCategory = newCategory;
      });
      _loadMenuProducts();
    }
  }

  Future<void> _removeProductFromMenu(MenuProduct product) async {
    // Confirmación antes de eliminar
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Producto'),
        content: Text('¿Está seguro que desea eliminar "${product.product?['name'] ?? 'este producto'}" del menú?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldDelete) return;

    setState(() {
      _isDeletingProduct = true;
    });

    try {
      // Pasar el objeto MenuProduct completo en lugar de solo el ID
      await _menuService.removeProductFromMenu(
        widget.menuId,
        product // Pasar el objeto completo
      );
      
      // Actualizar la lista después de eliminar
      await _loadMenuProducts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el producto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingProduct = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos del Menú'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: _onCategoryChanged,
            items: <String>[
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
              'Cuchareables'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading || _isDeletingProduct
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _loadMenuProducts,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? Center(child: Text('No hay productos en esta categoría'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Dismissible(
                          key: Key(product.id.toString()),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar Producto'),
                                content: Text('¿Está seguro que desea eliminar "${product.product?['name'] ?? 'este producto'}" del menú?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (direction) {
                            _removeProductFromMenu(product);
                          },
                          child: ListTile(
                            title: Text(product.product?['name'] ?? 'Producto sin nombre'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Precio: ${product.product?['price'] ?? 'N/A'}'),
                                Text('Categoría: ${product.product?['category'] ?? 'N/A'}'),  // Mostrar categoría en lugar del ID
                              ],
                            ),
                            leading: Icon(Icons.fastfood),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeProductFromMenu(product),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}