import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_service.dart';

class ManageSuppliesDetails extends StatefulWidget {
  final int supplyId;
  final String supplyName;
  final String unit;
  final int branchId;
  final double purchased; // Cantidad comprada
  final double remaining; // Cantidad restante

  const ManageSuppliesDetails({
    Key? key,
    required this.supplyId,
    required this.supplyName,
    required this.unit,
    required this.branchId,
    required this.purchased,
    required this.remaining,
  }) : super(key: key);

  @override
  State<ManageSuppliesDetails> createState() => _ManageSuppliesDetailsState();
}

class _ManageSuppliesDetailsState extends State<ManageSuppliesDetails> {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 220, 230),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra superior con título
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 236, 113, 158), // Color rosa del header
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Editar Detalle del Insumo",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido del formulario
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Insumo: ${widget.supplyName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cantidad comprada: ${widget.purchased} ${widget.unit}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo de cantidad consumida
                  TextFormField(
                    controller: _consumedController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2.0,           
                        ),
                      ),
                      hintText: 'Cantidad consumida (${widget.unit})',
                      hintStyle: TextStyle(
                        fontSize: 16.0,        
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                      contentPadding: EdgeInsets.only(bottom: -10),
                      errorText: _consumedController.text.isNotEmpty &&
                              double.tryParse(_consumedController.text) != null &&
                              double.parse(_consumedController.text) > widget.purchased
                          ? 'Cantidad mayor que la comprada'
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
                  
                  const SizedBox(height: 16),
                  Text(
                    'Cantidad restante: $_calculatedRemaining ${widget.unit}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botones de acción
            Padding(
              padding: EdgeInsets.only(bottom: 16, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitConsumption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 236, 113, 158),
                      disabledBackgroundColor: Color.fromARGB(255, 236, 113, 158).withOpacity(0.5),
                    ),
                    child: _isLoading 
                        ? SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              color: Colors.white
                            )
                          ) 
                        : Text(
                            "Guardar", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}