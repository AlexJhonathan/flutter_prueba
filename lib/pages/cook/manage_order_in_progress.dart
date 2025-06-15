import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/order_service.dart';

class ManageOrderInProgress extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> products;

  const ManageOrderInProgress({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.products,
  }) : super(key: key);

  @override
  State<ManageOrderInProgress> createState() => _ManageOrderInProgressState();
}

class _ManageOrderInProgressState extends State<ManageOrderInProgress> {
  final OrderService _orderService = OrderService();
  bool _isSubmitting = false;
  String? _error;

  Future<void> _markAsComplete() async {
    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      await _orderService.updateOrder(
        orderId: widget.orderId,
        status: 3,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido marcado como completo'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error al marcar el pedido como completo: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromRGBO(255, 220, 230, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Pedido en Curso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFED7A9E),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Mesa: ${widget.orderDetails['tableId']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Productos:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: widget.products.isEmpty
                      ? const Center(child: Text('No hay productos disponibles para este pedido'))
                      : ListView.builder(
                          itemCount: widget.products.length,
                          itemBuilder: (context, index) {
                            final product = widget.products[index];
                            final Map<String, dynamic>? productData = product['Product'];
                            final productName = productData?['name'] ?? 'Nombre no disponible';
                            final quantity = product['quantity'] ?? 0;
                            final subtotal = product['subtotal'] ?? 0.0;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(productName),
                                subtitle: Text('Cantidad: $quantity'),
                                trailing: Text('\$${subtotal.toStringAsFixed(2)}'),
                              ),
                            );
                          },
                        ),
                ),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFED7A9E),
                        side: const BorderSide(color: Color(0xFFED7A9E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: const Text('Cerrar'),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: _markAsComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFED7A9E),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Completar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
