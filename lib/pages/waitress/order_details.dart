import 'package:flutter/material.dart';
import 'package:flutter_prueba/pages/waitress/waitress_page.dart';
import 'package:flutter_prueba/services/order_service.dart';
import 'package:flutter_prueba/pages/waitress/order_in_progress.dart';

class OrderDetails extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderDetails;
  final List<Map<String, dynamic>> selectedProducts;

  const OrderDetails({
    Key? key,
    required this.orderId,
    required this.orderDetails,
    required this.selectedProducts,
  }) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
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

      await _orderService.updateOrder(
        orderId: widget.orderId,
        notes: _notesController.text,
        total: _total,
        status: 1,
      );

      final updatedOrder = await _orderService.getOrderById(widget.orderId);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => OrderInProgress(
            orderDetails: updatedOrder,
            onClose: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WaitressPage(branchId: updatedOrder['branchId'] ?? 1),
                ),
              );
            },
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
      backgroundColor: Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        title: const Text('DETALLE PEDIDO'),
        centerTitle: true,
        backgroundColor: Color(0xFFED7A9E),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildOrderDetails(),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGeneralDetails(),
        const SizedBox(height: 12),
        const Divider(thickness: 1.2),
        const SizedBox(height: 8),
        const Text(
          'PRODUCTOS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildProductList()),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildGeneralDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mesa: ${widget.orderDetails['tableId']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.pink.shade100),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _notesController,
            decoration: const InputDecoration.collapsed(
              hintText: 'Ej: Sin cebolla, término medio...',
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: widget.selectedProducts.length,
      itemBuilder: (context, index) {
        final product = widget.selectedProducts[index];
        final name = product['name'];
        final price = product['price'];
        final quantity = product['quantity'];
        final subtotal = price * quantity;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 238, 166, 190), Color.fromARGB(255, 250, 190, 196)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade100,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Precio: \$${price.toStringAsFixed(2)} x $quantity'),
            trailing: Text(
              '\$${subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFED7A9E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirmar Pedido', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFFED7A9E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFED7A9E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Volver', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
