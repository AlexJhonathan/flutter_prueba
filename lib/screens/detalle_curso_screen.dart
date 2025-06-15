import 'package:flutter/material.dart';
import '../services/order_service.dart';

class DetalleCursoScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> products;

  const DetalleCursoScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.products,
  }) : super(key: key);

  @override
  _DetalleCursoScreenState createState() => _DetalleCursoScreenState();
}

class _DetalleCursoScreenState extends State<DetalleCursoScreen> {
  final OrderService _orderService = OrderService();
  bool _isSubmitting = false;
  String? _error;

  Future<void> _markAsComplete() async {
    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      // Cambiar el estado del pedido a 3 (Completo)
      await _orderService.updateOrder(
        orderId: widget.orderId,
        status: 3,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido marcado como completo')),
        );

        // Regresar a la pantalla anterior
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Pedido en Curso'),
      ),
      body: Stack(
        children: [
          _buildOrderDetails(),
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesa: ${widget.orderDetails['tableId']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Productos:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: widget.products.isEmpty
                ? const Center(
                    child: Text('No hay productos disponibles para este pedido'),
                  )
                : ListView.builder(
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      final productName = product['Product']?['name'] ?? 'Nombre no disponible';
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
          const SizedBox(height: 16),
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              child: Text(
                'Error: $_error',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Regresar a la pantalla anterior
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Atrás'),
              ),
              ElevatedButton(
                onPressed: _markAsComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Listo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}