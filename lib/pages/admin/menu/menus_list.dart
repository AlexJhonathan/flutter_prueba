import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/menu_list_service.dart';
import 'package:flutter_prueba/models/menu_list_model.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:flutter_prueba/pages/admin/menu/menus_products_list.dart';
import 'package:flutter_prueba/pages/admin/menu/menu_add.dart';
import 'package:flutter_prueba/pages/admin/menu/menu_edit.dart';

class MenusList extends StatefulWidget {
  @override
  _MenusListState createState() => _MenusListState();
}

class _MenusListState extends State<MenusList> {
  final _menuService = MenuListService();
  List<Menu> _menus = [];
  bool _isLoading = true;
  bool _isDeletingMenu = false;
  String? _error;
  int? _selectedBranchId; // para filtrar por sucursal

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  // Función para obtener el nombre de la sucursal según ID
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

  // Función para formatear fecha
  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _fetchMenus() async {
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

  

  // Solo filtramos los menús si seleccionan una sucursal
  List<Menu> get filteredMenus {
    if (_selectedBranchId == null) {
      return _menus;
    } else {
      return _menus.where((menu) => menu.branchId == _selectedBranchId).toList();
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
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
                        onPressed: _fetchMenus,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "MENÚS",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color.fromARGB(255, 236, 113, 158), width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int?>(
                                    isExpanded: true,
                                    value: _selectedBranchId,
                                    hint: Text('Seleccionar Sucursal'),
                                    items: [
                                      DropdownMenuItem(value: null, child: Text('Todos')),
                                      DropdownMenuItem(value: 3, child: Text('Tarija Principal')),
                                      DropdownMenuItem(value: 4, child: Text('Tarija Parque')),
                                      DropdownMenuItem(value: 5, child: Text('La Paz Principal')),
                                      DropdownMenuItem(value: 6, child: Text('La Paz Mega')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedBranchId = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/productlist');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 237, 122, 158),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Productos"),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredMenus.length,
                          itemBuilder: (context, index) {
                            final menu = filteredMenus[index];
                            return ExpandableMenuItem(
                              menu: menu,
                              branchName: getBranchName(menu.branchId),
                              createdAt: formatDateTime(menu.createdAt),
                              updatedAt: formatDateTime(menu.updatedAt),
                              onRefresh: _fetchMenus,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),


                floatingActionButton: FloatingActionButton(
                  backgroundColor: Color.fromARGB(255, 237, 122, 158),
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (_) => MenuAdd(),
                    );

                    if (result == true) {
                      await _fetchMenus(); // ← Esto actualizará la lista correctamente
                    }
                  }
                ),

    );
  }
}


class ExpandableMenuItem extends StatefulWidget {
  final Menu menu;
  final String branchName;
  final String createdAt;
  final String updatedAt;
  final VoidCallback onRefresh;
  

  const ExpandableMenuItem({
    Key? key,
    required this.menu,
    required this.branchName,
    required this.createdAt,
    required this.updatedAt,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<ExpandableMenuItem> createState() => _ExpandableMenuItemState();
}

class _ExpandableMenuItemState extends State<ExpandableMenuItem> {
  bool isExpanded = false;
  final _menuService = MenuListService();
  List<Menu> _menus = [];
  bool _isLoading = true;
  bool _isDeletingMenu = false;
  String? _error;
  int? _selectedBranchId;
  

  Future<void> _fetchMenus() async {
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

  Future<void> _deleteMenu(Menu menu) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Menú'),
        content: Text(
          '¿Está seguro que desea eliminar "${menu.name}"? Esta acción eliminará también todos los productos asociados a este menú.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menú eliminado correctamente')),
        );
        widget.onRefresh(); // Recargar lista desde el padre
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el menú: $e')),
        );
      }
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
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            padding: const EdgeInsets.only(top: 15, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 237, 129, 163),
                  Color.fromARGB(255, 255, 182, 193),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.menu.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => MenuEdit(menu: widget.menu)
                        );

                        if (result == true) {
                          widget.onRefresh(); 
                        }
                      },
                      tooltip: 'Editar Menú',
                    ),

                
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: _isDeletingMenu
                          ? null
                          : () => _deleteMenu(widget.menu),
                      tooltip: 'Eliminar Menú',
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 0),
                Text(
                  'Estado: ${widget.menu.status ? "ACTIVO" : "INACTIVO"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 0.9, ), 
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 231, 238),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sucursal: ${widget.branchName}'),
                Text('Creado: ${widget.createdAt}'),
                Text('Actualizado: ${widget.updatedAt}'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenusProductsList(menuId: widget.menu.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list, color: Colors.white,),
                      label: const Text("Ver Productos", style: const TextStyle(color: Colors.white, fontSize: 14),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 182, 193),
                      ),
                    ),
                    
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      
      
    );
  
  }
}


