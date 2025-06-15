import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/order_service.dart';

class ManageOrder extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> products;
  final int cookId;

  const ManageOrder({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.products,
    required this.cookId,
  }) : super(key: key);

  @override
  State<ManageOrder> createState() => _ManageOrderState();
}

class _ManageOrderState extends State<ManageOrder> {
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
                  'Detalle del Pedido',
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Productos:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 179, 199), // rosa oscuro
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(
                  minHeight: 60,
                  maxHeight: 150,
                  minWidth: double.infinity,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    'Notas: ${widget.orderDetails['notes'] ?? 'Sin notas'}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                      
                          backgroundColor: const Color.fromRGBO(255, 220, 230, 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Text('¿Negar Pedido?', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              labelText: 'Motivo de rechazo',
                              hintText: 'Explique por qué rechaza el pedido',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          actions: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFED7A9E),
                                side: const BorderSide(color: Color(0xFFED7A9E)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_commentController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Por favor, indique el motivo del rechazo'),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context); // Cierra el AlertDialog
                                _updateOrder(4); // Llama a la función de rechazo
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF7B3F61),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3F61),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Negar', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),

                  const SizedBox(width: 8),

                  ElevatedButton(
                    onPressed: () {
                      _updateOrder(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFED7A9E), // rosa
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    ),
  );
}

}
