import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_prueba/pages/auth/login_page.dart';
import 'package:flutter_prueba/pages/cook/manage_order.dart';
import 'package:flutter_prueba/pages/cook/manage_order_in_progress.dart';
import 'package:flutter_prueba/pages/cook/manage_supplies.dart';
import 'package:flutter_prueba/pages/cook/manage_products.dart';
import 'package:flutter_prueba/services/order_service.dart';

class CookPage extends StatefulWidget {
  final int branchId;

  const CookPage({Key? key, required this.branchId}) : super(key: key);

  @override
  State<CookPage> createState() => _CookPageState();
}

class _CookPageState extends State<CookPage> {
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
        return Color.fromARGB(255, 247, 165, 140);
      case 2:
        return Color(0xFF9D5DA5);
      case 3:
        return Color.fromARGB(255, 237, 122, 158);
      default:
        return 	Color(0xFF7B3F61);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 122, 158),
        title: const Text('Repostera', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              final status = order['status'] as int;

                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.pink[100],
                                        child: const Icon(Icons.receipt_long, color: Colors.black87),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Pedido #${order['id']}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('Mesa: ${order['tableId']}', style: const TextStyle(color: Colors.grey)),
                                                  if ((order['notes'] ?? '').toString().isNotEmpty)
                                                    Text('Notas: ${order['notes']}', style: const TextStyle(color: Colors.grey)),
                                                  Text('Total: \$${order['total']}', style: const TextStyle(fontSize: 14)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton(
                                             
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _getStatusColor(status),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              onPressed: () async {
                                                // mismo código del onPressed actual...
                                                if (status == 1) {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  final cookId = prefs.getInt('userId') ?? 0;
                                                  if (cookId == 0) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Error: No se encontró el ID del usuario')),
                                                    );
                                                    return;
                                                  }

                                                  final orderDetails = await _orderService.getOrderById(order['id']);
                                                  final products = (await _orderService.getOrderProducts(order['id']))
                                                      .cast<Map<String, dynamic>>();

                                                  final result = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => ManageOrder(
                                                      orderId: order['id'],
                                                      orderDetails: orderDetails,
                                                      products: products,
                                                      cookId: cookId,
                                                    ),
                                                  );

                                                  if (result == true) _fetchOrders();
                                                } else if (status == 2) {
                                                  final orderDetails = await _orderService.getOrderById(order['id']);
                                                  final products = (await _orderService.getOrderProducts(order['id']))
                                                      .cast<Map<String, dynamic>>();

                                                  final result = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => ManageOrderInProgress(
                                                        orderId: order['id'],
                                                        orderDetails: orderDetails,
                                                        products: products,
                                                      ),
                                                  );

                                                  if (result == true) _fetchOrders();
                                                }
                                              },
                                              child: Text(_getStatusText(status)),
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageSupplies()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED7A9E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Insumos', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageProducts(branchId: widget.branchId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED7A9E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Productos', style: TextStyle(color: Colors.white, fontSize: 16), ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
