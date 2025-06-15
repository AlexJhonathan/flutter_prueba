import 'package:flutter/material.dart';
import 'package:flutter_prueba/models/branch_model.dart';
import 'package:flutter_prueba/services/branch_service.dart';
import 'package:flutter_prueba/services/user_service.dart';
import 'package:flutter_prueba/models/user_model.dart';

class PersonalEdit extends StatefulWidget {

  final User user;
  const PersonalEdit({Key? key, required this.user}) : super(key: key);

  @override
  _PersonalEditState createState() => _PersonalEditState();
}

class _PersonalEditState extends State<PersonalEdit> {
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  int? _selectedRoleId;
  late int _branchId;
  late bool _status;

  bool _isLoading = false;


  
  final List<Map<String, dynamic>> _branches = [
    {'id': 1, 'name': 'General'},
    {'id': 3, 'name': 'Tarija Principal'},
    {'id': 4, 'name': 'Tarija Parque'},
    {'id': 5, 'name': 'La Paz Principal'},
    {'id': 6, 'name': 'La Paz Mega'},
  ];

  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'name': 'Administrador'},
    {'id': 2, 'name': 'Repostera'},
    {'id': 3, 'name': 'Mesera'},
  ];


  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController(text: widget.user.password);
    _selectedRoleId = widget.user.role;
    _branchId = widget.user.branchId;
    _status = widget.user.status;
  }



  @override
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el email';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un rol')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _userService.updateUser(
        widget.user.id,
        _nombreController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRoleId!,
        _branchId,
        _status,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.error == null || response.error!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 0,
          ),
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
                      "Editar Personal",
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontSize: 16.0,        
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        validator: _validateEmail,
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 10),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,           
                            ),
                          ),
                          hintText: 'Contraseña',
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


                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14),
                      child: DropdownButtonFormField<int>(
                        value: _selectedRoleId,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.0),
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        hint: Text(
                          'Rol',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem<int>(
                            value: role['id'],
                            child: Text(role['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRoleId = value;
                          });
                        },
                        validator: (value) => value == null ? 'Seleccione un rol' : null,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14),
                      child: DropdownButtonFormField<int>(
                        value: _branchId,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.0),
                          ),
                          contentPadding: EdgeInsets.only(bottom: -10),
                        ),
                        hint: Text(
                          'Seleccione la sucursal',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                        ),
                        items: _branches.map((branch) {
                          return DropdownMenuItem<int>(
                            value: branch['id'],
                            child: Text(branch['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _branchId = value!;
                          });
                        },
                        validator: (value) => value == null ? 'Seleccione una sucursal' : null,
                      ),
                    ),


                    Padding(
                      padding: EdgeInsetsDirectional.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w200,
                              color: Colors.black,
                            ),
                          ),
                          Switch(
                            value: _status,
                            onChanged: (value) {
                              setState(() {
                                _status = value;
                              });
                            },
                            activeColor: Color.fromARGB(255, 236, 101, 151),
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ],
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
                       _updateUser();
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
