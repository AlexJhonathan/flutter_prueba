import 'package:flutter/material.dart';

class OrderInProgress extends StatelessWidget {
  final Map<String, dynamic> orderDetails;
  final VoidCallback onClose;

  const OrderInProgress({
    Key? key,
    required this.orderDetails,
    required this.onClose,
  }) : super(key: key);

  String _getStatusText(int? status) {
    switch (status) {
      case 1:
        return 'En espera';
      case 2:
        return 'En proceso';
      case 3:
        return 'Completado';
      case 4:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tableId = orderDetails['tableId'] ?? 'N/A';
    final total = orderDetails['total'] ?? 0.0;
    final notes = orderDetails['notes'] ?? '';
    final status = _getStatusText(orderDetails['status']);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Pedido enviado',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Estado: $status', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                border: Border.all(color: Colors.pink.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen del pedido', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Mesa: $tableId'),
                  Text('Total: \$${total.toStringAsFixed(2)}'),
                  if (notes.isNotEmpty) Text('Notas: $notes'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 237, 122, 158),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onClose,
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
