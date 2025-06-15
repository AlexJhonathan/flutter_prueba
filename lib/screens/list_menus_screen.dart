import 'package:flutter/material.dart';
import '../services/menu_list_service.dart';
import '../models/menu_list_model.dart';
import 'list_products_screen.dart';
import 'list_menu_products_screen.dart';
import 'add_menu_products_screen.dart';
import 'create_menu_screen.dart';
import 'edit_menu_screen.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class ListMenusScreen extends StatefulWidget {
  @override
  _ListMenusScreenState createState() => _ListMenusScreenState();
}

class _ListMenusScreenState extends State<ListMenusScreen> {
  final MenuListService _menuService = MenuListService();
  List<Menu> _menus = [];
  bool _isLoading = true;
  bool _isDeletingMenu = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  // Función para obtener el nombre de la sucursal según el ID
  String getBranchName(int branchId) {
    switch (branchId) {
      case 3:
        return 'Tarija Principal';
      case 4:
        return 'Tarija Parque';
      case 5:
        return 'La Paz Principal';
      case 6:
        return 'La Paz Mega';
      default:
        return 'Sucursal $branchId';
    }
  }

  // Función para formatear fecha y hora
  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _loadMenus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final menus = await _menuService.getMenus();
      if (mounted) {
        setState(() {
          _menus = menus;
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

  void _navigateToCreateMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMenuScreen(),
      ),
    ).then((_) {
      _loadMenus();
    });
  }

  void _viewMenuProducts(int menuId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListMenuProductsScreen(menuId: menuId),
      ),
    );
  }

  void _addMenuProducts(int menuId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuProductsScreen(menuId: menuId),
      ),
    ).then((result) {
      if (result == true) {
        _loadMenus();
      }
    });
  }

  void _viewAllProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListProductsScreen(),
      ),
    );
  }

  Future<void> _deleteMenu(Menu menu) async {
    // Confirmación antes de eliminar el menú
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Menú'),
        content: Text('¿Está seguro que desea eliminar "${menu.name}"? Esta acción eliminará también todos los productos asociados a este menú.'),
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
      _isDeletingMenu = true;
    });

    try {
      await _menuService.deleteMenu(menu.id);
      
      // Actualizar la lista después de eliminar
      await _loadMenus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menú eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el menú: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingMenu = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Menús'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMenus,
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _viewAllProducts,
          ),
        ],
      ),
      body: _isLoading || _isDeletingMenu
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _loadMenus,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _menus.length,
                  itemBuilder: (context, index) {
                    final menu = _menus[index];
                    return Dismissible(
                      key: Key(menu.id.toString()),
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
                            title: Text('Eliminar Menú'),
                            content: Text('¿Está seguro que desea eliminar "${menu.name}"? Esta acción eliminará también todos los productos asociados a este menú.'),
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
                        _deleteMenu(menu);
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 2,
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  menu.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Switch eliminado
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMenuScreen(menu: menu),
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      _loadMenus();
                                    }
                                  });
                                },
                                tooltip: 'Editar Menú',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteMenu(menu),
                                tooltip: 'Eliminar Menú',
                              ),
                            ],
                          ),
                          // Ya no mostrar el ID en el subtítulo
                          subtitle: Text(menu.status ? 'Activo' : 'Inactivo'),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mostrar nombre de sucursal en vez de ID
                                  Text(
                                    'Sucursal: ${getBranchName(menu.branchId)}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  // Formatear fechas
                                  Text(
                                    'Creado: ${formatDateTime(menu.createdAt)}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Actualizado: ${formatDateTime(menu.updatedAt)}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.restaurant_menu),
                                        label: Text('Ver Productos'),
                                        onPressed: () => _viewMenuProducts(menu.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.add_circle),
                                        label: Text('Añadir Productos'),
                                        onPressed: () => _addMenuProducts(menu.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMenu,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        tooltip: 'Añadir Nuevo Menú',
      ),
    );
  }
}