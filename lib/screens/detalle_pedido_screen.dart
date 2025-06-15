import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'pedido_en_curso_screen.dart';

class DetallePedidoScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails; // Detalles generales del pedido
  final List<Map<String, dynamic>> selectedProducts; // Productos seleccionados

  const DetallePedidoScreen({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.selectedProducts,
  }) : super(key: key);

  @override
  _DetallePedidoScreenState createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final TextEditingController _notesController = TextEditingController();
  final OrderService _orderService = OrderService();

  bool _isSubmitting = false;
  String? _error;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.orderDetails['notes'] ?? '';
    _calculateTotal();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var product in widget.selectedProducts) {
      final price = product['price'] as double;
      final quantity = product['quantity'] as int;
      total += price * quantity;
    }
    setState(() {
      _total = total;
    });
  }

  Future<void> _confirmOrder() async {
    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      // Actualizar el pedido con las notas y el total final
      await _orderService.updateOrder(
        orderId: widget.orderId,
        notes: _notesController.text,
        total: _total,
        status: 1, // Estado "activo"
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Navegar a la pantalla de pedido en curso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PedidoEnCursoScreen(
              orderId: widget.orderId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al confirmar el pedido: $_error')),
        );
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Confirmando pedido...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildGeneralDetails(),
              const Divider(),
              _buildProductList(),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildGeneralDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesa: ${widget.orderDetails['tableId']}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notas adicionales',
              border: OutlineInputBorder(),
              hintText: 'Ej: Sin cebolla, término medio, etc.',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: widget.selectedProducts.map((product) {
        final productName = product['name'] as String;
        final quantity = product['quantity'] as int;
        final price = product['price'] as double;
        final subtotal = price * quantity;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(productName),
            subtitle: Text('Precio: \$${price.toStringAsFixed(2)} x $quantity'),
            trailing: Text(
              '\$${subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _confirmOrder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Pedido', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Volver', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}