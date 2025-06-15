import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'mesera_screen.dart';

class PedidoEnCursoScreen extends StatefulWidget {
  final int orderId;

  const PedidoEnCursoScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  _PedidoEnCursoScreenState createState() => _PedidoEnCursoScreenState();
}

class _PedidoEnCursoScreenState extends State<PedidoEnCursoScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  Map<String, dynamic>? _orderDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Obtener los detalles del pedido
      final orderDetails = await _orderService.getOrderById(widget.orderId);

      if (mounted) {
        setState(() {
          _orderDetails = orderDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido en Curso'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildOrderDetails(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Error al cargar el pedido',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            child: const Text('Reintentar'),
          ),
          ElevatedButton(
            onPressed: _navigateToMesas,
            child: const Text('Inicio'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    final tableId = _orderDetails?['tableId'] ?? 'N/A';
    final total = _orderDetails?['total'] ?? 0.0;
    final notes = _orderDetails?['notes'] ?? '';
    final status = _getStatusText(_orderDetails?['status']);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            'Pedido enviado',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Estado: $status',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del pedido',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Mesa: $tableId'),
                Text('Total: \$${total.toStringAsFixed(2)}'),
                if (notes.isNotEmpty) Text('Notas: $notes'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToMesas,
            child: const Text('Inicio'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

 void _navigateToMesas() {
  final branchId = _orderDetails?['branchId'] ?? 1; // Valor predeterminado si no está disponible

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => MeseraScreen(branchId: branchId),
    ),
    (route) => false,
  );
}

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
}