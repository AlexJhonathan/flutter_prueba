import 'package:flutter/material.dart';
import '../services/supply_service.dart';

class RegistrarDetalleInsumoScreen extends StatefulWidget {
  final int supplyId;
  final String supplyName;
  final String unit;
  final int branchId;
  final double purchased; // Cantidad comprada
  final double remaining; // Cantidad restante

  const RegistrarDetalleInsumoScreen({
    Key? key,
    required this.supplyId,
    required this.supplyName,
    required this.unit,
    required this.branchId,
    required this.purchased,
    required this.remaining,
  }) : super(key: key);

  @override
  State<RegistrarDetalleInsumoScreen> createState() => _RegistrarDetalleInsumoScreenState();
}

class _RegistrarDetalleInsumoScreenState extends State<RegistrarDetalleInsumoScreen> {
  final TextEditingController _consumedController = TextEditingController();
  bool _isLoading = false;
  double _calculatedRemaining = 0.0;
  final SupplyService _service = SupplyService();

  @override
  void initState() {
    super.initState();
    // Calcular la cantidad consumida actual basado en comprado y restante
    final double currentConsumed = widget.purchased - widget.remaining;
    _consumedController.text = currentConsumed.toString();
    _calculatedRemaining = widget.remaining;
  }

  // Actualizar el remaining cuando cambia el consumed
  void _updateRemaining(String value) {
    double consumed = 0.0;
    try {
      consumed = double.parse(value);
    } catch (e) {
      consumed = 0.0;
    }
    
    setState(() {
      _calculatedRemaining = widget.purchased - consumed;
      if (_calculatedRemaining < 0) {
        _calculatedRemaining = 0;
      }
    });
  }

  Future<void> _submitConsumption() async {
    // Validar entrada
    if (_consumedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese la cantidad consumida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double consumed = 0.0;
    try {
      consumed = double.parse(_consumedController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese un número válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (consumed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad consumida no puede ser negativa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar que la cantidad consumida no sea mayor que la comprada
    if (consumed > widget.purchased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad consumida no puede ser mayor que la comprada'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Realizar la actualización usando el servicio
      await _service.actualizarConsumo({
        'supplyId': widget.supplyId,
        'branchId': widget.branchId,
        'purchased': widget.purchased,
        'consumed': consumed,
        'remaining': _calculatedRemaining,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consumo registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Regresar con éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el detalle: $e')),
        );
      }
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
        title: const Text('Editar Detalle del Insumo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insumo: ${widget.supplyName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cantidad comprada: ${widget.purchased} ${widget.unit}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _consumedController,
              decoration: InputDecoration(
                labelText: 'Cantidad consumida (${widget.unit})',
                labelStyle: const TextStyle(color: Colors.red),
                border: const OutlineInputBorder(),
                hintText: 'Ej: 2.5',
                errorText: _consumedController.text.isNotEmpty &&
                        double.tryParse(_consumedController.text) != null &&
                        double.parse(_consumedController.text) > widget.purchased
                    ? 'La cantidad consumida no puede ser mayor que la comprada'
                    : null,
                errorStyle: const TextStyle(color: Colors.red),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                _updateRemaining(value);
                // Forzar actualización para validar mientras escribe
                setState(() {});
              },
            ),
            if (_consumedController.text.isNotEmpty &&
                double.tryParse(_consumedController.text) != null &&
                double.parse(_consumedController.text) > widget.purchased)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'La cantidad consumida no puede ser mayor que la comprada',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Cantidad restante: $_calculatedRemaining ${widget.unit}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitConsumption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Guardar Cambios', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Atrás', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}