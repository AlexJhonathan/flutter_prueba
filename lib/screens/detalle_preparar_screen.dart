import 'package:flutter/material.dart';
import '../services/order_service.dart';

class DetallePrepararScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> products;
  final int cookId; // ID del cocinero que inició sesión

  const DetallePrepararScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.products,
    required this.cookId,
  }) : super(key: key);

  @override
  _DetallePrepararScreenState createState() => _DetallePrepararScreenState();
}

class _DetallePrepararScreenState extends State<DetallePrepararScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;
  bool _showCommentField = false;

  Future<void> _updateOrder(int status) async {
    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      String notes = widget.orderDetails['notes'] ?? '';
      if (status == 4 && _commentController.text.isNotEmpty) {
        notes = _commentController.text;
      }

      double total = widget.orderDetails['total'] is double
          ? widget.orderDetails['total']
          : (widget.orderDetails['total'] as num).toDouble();

      // Usar el cookId del usuario que inició sesión
      final int cookIdToSend = widget.cookId;

      await _orderService.updateOrder(
        orderId: widget.orderId,
        cookId: cookIdToSend,
        notes: notes,
        total: total,
        status: status,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 2
                ? 'Pedido aceptado correctamente'
                : 'Pedido rechazado correctamente'),
            backgroundColor: status == 2 ? Colors.green : Colors.red,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error al actualizar el pedido: $e');
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
        title: const Text('Detalle del Pedido'),
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
                  shrinkWrap: true,
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.products[index];

                    // Acceder al nombre del producto desde el objeto anidado "Product"
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
        const SizedBox(height: 16),
        Text(
          'Notas: ${widget.orderDetails['notes'] ?? 'Sin notas'}',
          style: const TextStyle(fontSize: 16),
        ),
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
        const Spacer(),
        if (_showCommentField)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Motivo de rechazo',
                hintText: 'Explique por qué rechaza el pedido',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_showCommentField) {
                  if (_commentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, indique el motivo del rechazo')),
                    );
                    return;
                  }
                  _updateOrder(4); // Cambiar a "Negado"
                } else {
                  setState(() {
                    _showCommentField = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(_showCommentField ? 'Confirmar Rechazo' : 'Negar'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateOrder(2); // Cambiar a "En curso"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ],
    ),
  );
}
}