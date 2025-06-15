import 'package:flutter/material.dart';
import 'package:flutter_prueba/models/branch_model.dart';
import 'package:flutter_prueba/services/branch_service.dart';

class BranchEdit extends StatefulWidget {
  final Branch branch;
  BranchEdit({required this.branch});

  @override
  _BranchEditState createState() => _BranchEditState();
}

class _BranchEditState extends State<BranchEdit> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _branchService = BranchService();
  

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.branch.name;
    _direccionController.text = widget.branch.address;
    _telefonoController.text = widget.branch.phone.toString();
  }

  Future<void> _updateBranch() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _branchService.updateBranch(
          widget.branch.id!,
          _nombreController.text,
          _direccionController.text,
          int.parse(_telefonoController.text),
        );
        Navigator.pop(context,true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la sucursal: $e')),
        );
        Navigator.pop(context,false);
      }
    }
  }

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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 236, 113, 158),// Color de la barra superior
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Editar Sucursal",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

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
                        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14),
                      child: TextFormField(
                        controller: _direccionController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Dirección',
                          hintStyle: TextStyle(
                            fontSize: 16.0,        
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 10),
                      child: TextFormField(
                        controller: _telefonoController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Teléfono',
                          hintStyle: TextStyle(
                            fontSize: 16.0,        
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateBranch();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 236, 113, 158),),
                    child: Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
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
