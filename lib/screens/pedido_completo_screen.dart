import 'package:flutter/material.dart';
import '../services/order_service.dart';

class PedidoCompletoScreen extends StatelessWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> products;

  const PedidoCompletoScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.products,
  }) : super(key: key);

  Future<void> _markAsDelivered(BuildContext context) async {
    final OrderService orderService = OrderService();
    try {
      // Cambiar el estado del pedido a 5 (Entregado)
      await orderService.updateOrder(
        orderId: orderId,
        status: 5,
      );

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como entregado')),
      );

      // Regresar a la pantalla anterior
      Navigator.pop(context, true);
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como entregado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido Completo #$orderId'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mesa: ${orderDetails['tableId']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Productos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text('No hay productos disponibles para este pedido'),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
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
                  onPressed: () => _markAsDelivered(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Entregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}