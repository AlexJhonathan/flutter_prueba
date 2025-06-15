import 'package:flutter/material.dart';
import '../services/supply_service.dart';
import 'registrar_detalle_insumo_screen.dart'; // Nueva pantalla para registrar el detalle del insumo

class InsumosPorCategoriaScreen extends StatefulWidget {
  final String categoria;

  const InsumosPorCategoriaScreen({
    Key? key,
    required this.categoria,
  }) : super(key: key);

  @override
  State<InsumosPorCategoriaScreen> createState() => _InsumosPorCategoriaScreenState();
}

class _InsumosPorCategoriaScreenState extends State<InsumosPorCategoriaScreen> {
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
    try {
      final supplyDetail = await _service.getSupplyDetailById(supplyId, branchId);
      
      // Cerrar el indicador de carga
      Navigator.pop(context);
      
      if (supplyDetail != null) {
        // Navegar a la pantalla con los datos actualizados
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrarDetalleInsumoScreen(
              supplyId: supplyDetail.supplyId,
              supplyName: supplyDetail.supply.name,
              unit: supplyDetail.supply.unit,
              branchId: supplyDetail.branchId,
              purchased: supplyDetail.purchased,
              remaining: supplyDetail.remaining,
            ),
          ),
        );
        
        // Si hay cambios, actualizar la lista de insumos
        if (result == true) {
          cambiosRealizados = true;
          cargarInsumos();
        }
      } else {
        // Si no hay detalles, usar los datos básicos del insumo
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrarDetalleInsumoScreen(
              supplyId: supplyId,
              supplyName: insumoData['name'] ?? 'Sin nombre',
              unit: insumoData['unit'] ?? 'unidad',
              branchId: branchId,
              purchased: insumoData['purchased']?.toDouble() ?? 0.0,
              remaining: insumoData['remaining']?.toDouble() ?? 0.0,
            ),
          ),
        );
        
        // Si hay cambios, actualizar la lista de insumos
        if (result == true) {
          cambiosRealizados = true;
          cargarInsumos();
        }
      }
    } catch (detailError) {
      // Si hay error al obtener detalles, cerrar el diálogo de carga
      Navigator.pop(context);
      
      // Usar datos básicos del insumo
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrarDetalleInsumoScreen(
            supplyId: supplyId,
            supplyName: insumoData['name'] ?? 'Sin nombre',
            unit: insumoData['unit'] ?? 'unidad',
            branchId: branchId,
            purchased: insumoData['purchased']?.toDouble() ?? 0.0,
            remaining: insumoData['remaining']?.toDouble() ?? 0.0,
          ),
        ),
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
        appBar: AppBar(
          title: Text('Insumos - ${widget.categoria}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(cambiosRealizados);
            },
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
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
                          child: const Text('Intentar de nuevo'),
                        ),
                      ],
                    ),
                  )
                : insumos.isEmpty
                    ? Center(
                        child: Text('No hay insumos en la categoría ${widget.categoria}'),
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

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.category, size: 16),
                                            const SizedBox(width: 4),
                                            Text('Categoría: ${widget.categoria}'),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.straighten, size: 16),
                                            const SizedBox(width: 4),
                                            Text('Unidad: $unidad'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botón para registrar detalle
                                  if (id != null)
                                    IconButton(
                                      onPressed: () => _abrirDetalleInsumo(id, 0), // Usando la nueva función
                                      icon: const Icon(
                                        Icons.edit_note,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Registrar detalle',
                                    ),
                                  // Botón para eliminar
                                  if (id != null)
                                    IconButton(
                                      onPressed: () => eliminarInsumo(id, nombre),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Eliminar insumo',
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}