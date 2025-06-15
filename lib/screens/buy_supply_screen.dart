import 'package:flutter/material.dart';
import '../services/supply_service.dart';

class BuySupplyScreen extends StatefulWidget {
  final int supplyId;
  final String supplyName;
  final String unit;
  final int branchId;

  const BuySupplyScreen({
    Key? key,
    required this.supplyId,
    required this.supplyName,
    required this.unit,
    required this.branchId,
  }) : super(key: key);

  @override
  State<BuySupplyScreen> createState() => _BuySupplyScreenState();
}

class _BuySupplyScreenState extends State<BuySupplyScreen> {
  final SupplyService _supplyService = SupplyService();
  final TextEditingController _purchasedController = TextEditingController();
  bool _isLoading = false;
  final int _userId = 18; // ID de usuario fijo como mencionaste

  Future<void> _submitPurchase() async {
    // Validar entrada
    if (_purchasedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese la cantidad comprada'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double purchased = double.tryParse(_purchasedController.text) ?? 0;
    if (purchased <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad debe ser mayor que cero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double consumed = 0; // Siempre 0 para nuevas compras
    final double remaining = purchased - consumed; // Calculado automáticamente

    setState(() {
      _isLoading = true;
    });

    try {
      await _supplyService.registrarCompra({
        'supplyId': widget.supplyId,
        'branchId': widget.branchId,
        'userId': _userId,
        'purchased': purchased,
        'consumed': consumed,
        'remaining': remaining,
      });

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra registrada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Regresar a la pantalla anterior con resultado positivo
      Navigator.pop(context, true);
    } catch (e) {
      // Mostrar mensaje de error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comprar - ${widget.supplyName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.supplyName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID del Insumo: ${widget.supplyId}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unidad: ${widget.unit}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sucursal ID: ${widget.branchId}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detalle de compra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purchasedController,
              decoration: InputDecoration(
                labelText: 'Cantidad comprada (${widget.unit})',
                border: const OutlineInputBorder(),
                hintText: 'Ej: 10.5',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            Text(
              'Consumido: 0 ${widget.unit} (predeterminado)',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'REGISTRAR COMPRA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}