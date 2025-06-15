import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'mesera_screen.dart';
import 'detalle_preparar_screen.dart';
import 'detalle_curso_screen.dart';
import 'lista_categorias_screen.dart'; // Importar la pantalla ListaCategoriasScreen
import 'administrar_productos_screen.dart'; // Importar la pantalla de administrar productos
import '../services/order_service.dart';

class ReposteraScreen extends StatefulWidget {
  final int branchId;

  ReposteraScreen({required this.branchId});

  @override
  _ReposteraScreenState createState() => _ReposteraScreenState();
}

class _ReposteraScreenState extends State<ReposteraScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders = await _orderService.getOrdersByBranch(widget.branchId);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los pedidos: $e';
        _isLoading = false;
      });
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Preparar';
      case 2:
        return 'En curso';
      case 3:
        return 'Completo';
      default:
        return 'Negado';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text('Repostera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeseraScreen(branchId: widget.branchId),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Repostera'),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchOrders,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? const Center(child: Text('No hay pedidos disponibles'))
                        : ListView.builder(
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              final status = order['status'] as int;
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text('Pedido #${order['id']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Mesa: ${order['tableId']}'),
                                      Text('Notas: ${order['notes'] ?? 'Sin notas'}'),
                                      Text('Total: \$${order['total']}'),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () async {
                                      if (status == 1) {
                                        final prefs = await SharedPreferences.getInstance();
                                        final cookId = prefs.getInt('userId') ?? 0;

                                        if (cookId == 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Error: No se encontró el ID del usuario'),
                                            ),
                                          );
                                          return;
                                        }

                                        final orderDetails = await _orderService.getOrderById(order['id']);
                                        final products = (await _orderService.getOrderProducts(order['id']))
                                            .cast<Map<String, dynamic>>();

                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetallePrepararScreen(
                                              orderId: order['id'],
                                              orderDetails: orderDetails,
                                              products: products,
                                              cookId: cookId,
                                            ),
                                          ),
                                        );

                                        if (result == true) {
                                          _fetchOrders();
                                        }
                                      } else if (status == 2) {
                                        final orderDetails = await _orderService.getOrderById(order['id']);
                                        final products = (await _orderService.getOrderProducts(order['id']))
                                            .cast<Map<String, dynamic>>();

                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetalleCursoScreen(
                                              orderId: order['id'],
                                              orderDetails: orderDetails,
                                              products: products,
                                            ),
                                          ),
                                        );

                                        if (result == true) {
                                          _fetchOrders();
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getStatusColor(status),
                                    ),
                                    child: Text(_getStatusText(status)),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navegar a la pantalla ListaCategoriasScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListaCategoriasScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Registrar Insumos'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdministrarProductosScreen(branchId: widget.branchId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Administrar Productos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}