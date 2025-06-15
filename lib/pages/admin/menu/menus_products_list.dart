import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/models/menu_list_model.dart';
import 'package:flutter_prueba/pages/admin/menu/menus_products_add.dart';

class MenusProductsList extends StatefulWidget {
  final int menuId;

  MenusProductsList({required this.menuId});

  @override
  _MenusProductsListState createState() => _MenusProductsListState();
}

class _MenusProductsListState extends State<MenusProductsList> {
  final MenuListService _menuService = MenuListService();
  List<MenuProduct> _products = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'Todas';
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

      final products =
          await _menuService.getMenuProducts(widget.menuId, _selectedCategory);
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
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Eliminar Producto'),
            content: Text(
                '¿Está seguro que desea eliminar "${product.product?['name'] ?? 'este producto'}" del menú?'),
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
        ) ??
        false;

    if (!shouldDelete) return;

    setState(() {
      _isDeletingProduct = true;
    });

    try {
      await _menuService.removeProductFromMenu(widget.menuId, product);
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
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 237, 122, 158),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.white,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 40,
                    child: Text("PRODUCTOS DEL MENÚ",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w300)),
                  ),
                ),
              ),

              /// 👇 Dropdown movido justo debajo del título
              Center(
                child: DropdownButton<String>(
                  dropdownColor: Colors.pink[100],
                  value: _selectedCategory,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.pink[800]),
                  underline: Container(),
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
                      child: Text(value, style: TextStyle(color: Colors.pink[800])),
                    );
                  }).toList(),
                ),
              ),

              if (_isLoading || _isDeletingProduct)
                Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: TextStyle(color: Colors.red)),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadMenuProducts,
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_products.isEmpty)
                Expanded(
                    child:
                        Center(child: Text('No hay productos en esta categoría')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: ListTile(
                            leading: Icon(Icons.fastfood, color: Colors.white),
                            title: Text(
                              product.product?['name'] ?? 'Producto sin nombre',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Precio: ${product.product?['price'] ?? 'N/A'}\nCategoría: ${product.product?['category'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              color: Color.fromARGB(255, 236, 113, 158),
                              onPressed: () => _removeProductFromMenu(product),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 237, 122, 158),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => MenusProductsAdd(menuId: widget.menuId),
          );

          if (result == true) {
            _loadMenuProducts(); // Recargar productos si se agregaron nuevos
          }
        },
      ),
    );
  }
  
}

