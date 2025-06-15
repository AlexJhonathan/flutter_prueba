import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/supply_category_service.dart'; // Importar el servicio

class ManageSuppliesAdd extends StatefulWidget {
  @override
  _ManageSuppliesAddState createState() => _ManageSuppliesAddState();
}

class _ManageSuppliesAddState extends State<ManageSuppliesAdd> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController(); // Controlador para categoría

  final SupplyCategoryService _supplyCategoryService = SupplyCategoryService(); // Instancia del servicio
  bool _isLoading = false;

  Future<void> _guardarInsumo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final nombre = _nombreController.text;
      final unidad = _unidadController.text;
      final categoria = _categoriaController.text;

      try {
        await _supplyCategoryService.registrarInsumo(nombre, unidad, categoria);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insumo registrado exitosamente')),
          );
          Navigator.pop(context, true); // Regresar con valor true para indicar éxito
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrar el insumo: $e')),
          );
          setState(() => _isLoading = false);
        }
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
                      "Registrar Nuevo Insumo",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido del formulario
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14),
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Nombre',
                          hintStyle: TextStyle(
                            fontSize: 16.0,        
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14),
                      child: TextFormField(
                        controller: _unidadController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Unidad',
                          hintStyle: TextStyle(
                            fontSize: 16.0,        
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 10),
                      child: TextFormField(
                        controller: _categoriaController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Categoría',
                          hintStyle: TextStyle(
                            fontSize: 16.0,        
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                  ],
                ),
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
                    onPressed: _isLoading ? null : _guardarInsumo,
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