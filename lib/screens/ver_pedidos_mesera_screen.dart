import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'pedido_completo_screen.dart'; // Importar la pantalla PedidoCompletoScreen
import 'pedido_negado_screen.dart'; // Importar la pantalla PedidoNegadoScreen
import 'mesera_screen.dart'; // Importar la pantalla MeseraScreen

class VerPedidosMeseraScreen extends StatefulWidget {
  final int branchId;

  const VerPedidosMeseraScreen({Key? key, required this.branchId}) : super(key: key);

  @override
  _VerPedidosMeseraScreenState createState() => _VerPedidosMeseraScreenState();
}

class _VerPedidosMeseraScreenState extends State<VerPedidosMeseraScreen> {
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
      case 5:
        return 'Entregado';
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
      case 5:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos de la Mesera'),
      ),
      body: _isLoading
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
                            trailing: status == 1
                                ? ElevatedButton(
                                    onPressed: () {
                                      // Navegar a la pantalla MeseraScreen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MeseraScreen(branchId: widget.branchId),
                                        ),
                                      );
                                    },
                                    child: const Text('Editar'),
                                  )
                                : status == 2
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _getStatusText(status),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : status == 5
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Entregado',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              if (status == 3) {
                                                // Navegar a PedidoCompletoScreen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PedidoCompletoScreen(
                                                      orderId: order['id'],
                                                      orderDetails: {},
                                                      products: [],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // Navegar a PedidoNegadoScreen
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PedidoNegadoScreen(
                                                      orderId: order['id'],
                                                      orderDetails: {},
                                                      products: [],
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _getStatusText(status),
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                          ),
                        );
                      },
                    ),
    );
  }
}