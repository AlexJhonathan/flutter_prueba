import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_service.dart';

class SuppliesPurchase extends StatefulWidget {
  final int supplyId;
  final String supplyName;
  final String unit;
  final int branchId;

  const SuppliesPurchase({
    Key? key,
    required this.supplyId,
    required this.supplyName,
    required this.unit,
    required this.branchId,
  }) : super(key: key);

  @override
  State<SuppliesPurchase> createState() => _SuppliesPurchaseState();
}

class _SuppliesPurchaseState extends State<SuppliesPurchase> {
  final SupplyService _supplyService = SupplyService();
  final TextEditingController _purchasedController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final int _userId = 18;

  Future<void> _submitPurchase() async {
    if (_formKey.currentState!.validate()) {
      final double purchased = double.tryParse(_purchasedController.text) ?? 0;
      final double consumed = 0;
      final double remaining = purchased - consumed;

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

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra registrada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFED7A9E),
        title: Text('Comprar - ${widget.supplyName}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
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
                  Text('ID del Insumo: ${widget.supplyId}', style: const TextStyle(fontSize: 16)),
                  Text('Unidad: ${widget.unit}', style: const TextStyle(fontSize: 16)),
                  Text('Sucursal ID: ${widget.branchId}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text(
                    'Detalle de compra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _purchasedController,
                    label: 'Cantidad comprada (${widget.unit})',
                    hintText: 'Ej: 10.5',
                    validatorMessage: 'Por favor, ingrese la cantidad válida',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consumido: 0 ${widget.unit} (predeterminado)',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitPurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 236, 113, 158),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'REGISTRAR COMPRA',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        final parsed = double.tryParse(value ?? '');
        if (value == null || value.isEmpty || parsed == null || parsed <= 0) {
          return validatorMessage;
        }
        return null;
      },
    );
  }
}
