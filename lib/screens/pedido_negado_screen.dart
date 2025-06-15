import 'package:flutter/material.dart';

class PedidoNegadoScreen extends StatelessWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> products;

  const PedidoNegadoScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notes = orderDetails['notes'] ?? 'Sin notas'; // Obtener las notas del pedido

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido Negado #$orderId'),
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
            const SizedBox(height: 8),
            Text(
              'Notas: $notes',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
          ],
        ),
      ),
    );
  }
}