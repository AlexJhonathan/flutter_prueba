import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/order_service.dart';
import 'package:flutter_prueba/screens/pedido_completo_screen.dart';
import 'package:flutter_prueba/screens/pedido_negado_screen.dart';
import 'package:flutter_prueba/pages/waitress/waitress_page.dart';

class OrderList extends StatefulWidget {
  final int branchId;

  const OrderList({Key? key, required this.branchId}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
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
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 122, 158),
        elevation: 0,
        title: const Text(
          'Pedidos de la Mesera',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay pedidos disponibles',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _orders.length,
                      padding: const EdgeInsets.all(30),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final status = order['status'] as int;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color.fromARGB(255, 238, 166, 190), Color.fromARGB(255, 250, 190, 196)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.shade100.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pedido #${order['id']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Mesa: ${order['tableId']}'),
                                      Text('Notas: ${order['notes'] ?? 'Sin notas'}'),
                                      Text('Total: \$${order['total']}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildStatusButton(status, order),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildStatusButton(int status, dynamic order) {
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);

    if (status == 1) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitressPage(branchId: widget.branchId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 237, 122, 158),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Editar', style: TextStyle(color: Colors.white )),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (status == 3) {
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
          } else if (status != 2 && status != 5) {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
