import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_service.dart';
import 'package:flutter_prueba/pages/cook/manage_supplies_details.dart';

class ManageSuppliesList extends StatefulWidget {
  final String categoria;

  const ManageSuppliesList({
    Key? key,
    required this.categoria,
  }) : super(key: key);

  @override
  State<ManageSuppliesList> createState() => _ManageSuppliesListState();
}

class _ManageSuppliesListState extends State<ManageSuppliesList> {
  final SupplyService _service = SupplyService();
  List<Map<String, dynamic>> insumos = [];
  bool isLoading = true;
  String? error;
  bool cambiosRealizados = false;

  @override
  void initState() {
    super.initState();
    cargarInsumos();
  }

  Future<void> cargarInsumos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await _service.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final insumosData = await _service.obtenerInsumosPorCategoria(0, widget.categoria);
      setState(() {
        insumos = insumosData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  
  Future<void> _abrirDetalleInsumo(int supplyId, int branchId) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      
      // Obtener datos del insumo primero, para obtener nombre y unidad
      final insumosData = await _service.obtenerInsumosPorCategoria(branchId, widget.categoria);
      final insumoData = insumosData.firstWhere(
        (insumo) => insumo['id'] == supplyId,
        orElse: () => {'id': supplyId, 'name': 'Nombre no disponible', 'unit': 'unidad'},
      );
      
      // Obtener los datos del detalle actualizado si es posible
      double purchased = 0.0;
      double remaining = 0.0;
      String supplyName = insumoData['name'] ?? 'Sin nombre';
      String unit = insumoData['unit'] ?? 'unidad';
      
      try {
        final supplyDetail = await _service.getSupplyDetailById(supplyId, branchId);
        
        // Cerrar el indicador de carga
        Navigator.pop(context);
        
        if (supplyDetail != null) {
          // Usar datos del detalle
          supplyName = supplyDetail.supply.name;
          unit = supplyDetail.supply.unit;
          purchased = supplyDetail.purchased;
          remaining = supplyDetail.remaining;
        } else {
          // Si no hay detalles, usar los datos básicos del insumo
          purchased = insumoData['purchased']?.toDouble() ?? 0.0;
          remaining = insumoData['remaining']?.toDouble() ?? 0.0;
        }
      } catch (detailError) {
        // Si hay error al obtener detalles, cerrar el diálogo de carga
        Navigator.pop(context);
        
        // Usar datos básicos del insumo
        purchased = insumoData['purchased']?.toDouble() ?? 0.0;
        remaining = insumoData['remaining']?.toDouble() ?? 0.0;
      }
      
      // Mostrar el diálogo en lugar de navegar a una pantalla nueva
      if (context.mounted) {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ManageSuppliesDetails(
              supplyId: supplyId,
              supplyName: supplyName,
              unit: unit,
              branchId: branchId,
              purchased: purchased,
              remaining: remaining,
            );
          },
        );
        
        // Si hay cambios, actualizar la lista de insumos
        if (result == true) {
          cambiosRealizados = true;
          cargarInsumos();
        }
      }
    } catch (e) {
      // Cerrar el indicador de carga si hay error
      if (context.mounted) {
        Navigator.pop(context);
        
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> eliminarInsumo(int id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el insumo "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _service.actualizarConsumo({
        'supplyId': id,
        'branchId': 0, // Ajusta el branchId según sea necesario
        'purchased': 0,
        'consumed': 0,
        'remaining': 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insumo "$nombre" eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      cambiosRealizados = true;
      cargarInsumos();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(cambiosRealizados);
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 220, 230, 1), // Color de fondo rosa claro como en el ejemplo
        appBar: AppBar(
          title: Text('Insumos - ${widget.categoria}'),
          backgroundColor: Color(0xFFED7A9E), // Color rosa del appbar en el ejemplo
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(cambiosRealizados);
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Expanded(
                  child: isLoading
                    ? const Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFED7A9E)), // Color rosa para el indicador
                      ))
                    : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: $error',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: cargarInsumos,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFED7A9E), // Color rosa para el botón
                                ),
                                child: const Text(
                                  'Intentar de nuevo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : insumos.isEmpty
                        ? Center(
                            child: Text(
                              'No hay insumos en la categoría ${widget.categoria}',
                              style: TextStyle(fontSize: 16, color: Color(0xFFED7A9E)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: insumos.length,
                            itemBuilder: (context, index) {
                              final insumo = insumos[index];
                              final id = insumo['id'];
                              final nombre = insumo['name'] ?? 'Sin nombre';
                              final unidad = insumo['unit'] ?? 'No especificada';
                              final purchased = insumo['purchased'] ?? 0.0;
                              final consumed = insumo['consumed'] ?? 0.0;
                              final remaining = insumo['remaining'] ?? 0.0;
                
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color.fromARGB(255, 238, 166, 190), Color.fromARGB(255, 250, 190, 196)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                  child: ListTile(
                                    leading: const Icon(Icons.inventory_2, color: Colors.white), // Icono para insumos
                                    title: Text(
                                      nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.category, size: 16, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Categoría: ${widget.categoria}',
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.straighten, size: 16, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Unidad: $unidad',
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Botón para registrar detalle
                                        if (id != null)
                                          IconButton(
                                            onPressed: () => _abrirDetalleInsumo(id, 0),
                                            icon: const Icon(
                                              Icons.edit_note,
                                              color: Colors.white,
                                            ),
                                            tooltip: 'Registrar detalle',
                                          ),
                                        // Botón para eliminar
                                        if (id != null)
                                          IconButton(
                                            onPressed: () => eliminarInsumo(id, nombre),
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Color.fromARGB(255, 236, 113, 158),
                                            ),
                                            tooltip: 'Eliminar insumo',
                                          ),
                                      ],
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
      ),
    );
  }
}