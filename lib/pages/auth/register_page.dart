import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/employee_service.dart';

class RegisterPage extends StatefulWidget {

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  final _employeeService = EmployeeService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final _branchController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final response = await _employeeService.addEmployee(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          int.parse(_roleController.text),
          int.parse(_branchController.text),
        );

        setState(() => _isLoading = false);

        if (response.error.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Empleado agregado exitosamente')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.error)),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 236, 113, 158),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset( 
                  'lib/images/thecakee.png',
                  width: 130,
                  height: 200,
                ),

                SizedBox(
                  height: 70,
                  child: Text("REGISTRO USUARIOS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                ),

                SizedBox(
                  width: 285,
                  height: 30,
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) => value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black, // Aquí puedes poner el color que desees
                          width: 2.0,           // Aquí puedes ajustar el grosor
                        ),
                      ),
                      hintText: 'NOMBRE',
                      hintStyle: TextStyle(
                        fontSize: 16.0,        // Cambiar el tamaño de la fuente
                        fontWeight: FontWeight.w200, // Hacer el texto en negrita
                        color: Colors.black,   // Cambiar el color del label
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),
                
                SizedBox(
                  width: 285,
                  height: 30,
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) => value?.isEmpty ?? true ? 'Ingrese el email' : null,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black, // Aquí puedes poner el color que desees
                          width: 2.0,           // Aquí puedes ajustar el grosor
                        ),
                      ),
                      hintText: 'EMAIL',
                      hintStyle: TextStyle(
                        fontSize: 16.0,        // Cambiar el tamaño de la fuente
                        fontWeight: FontWeight.w200, // Hacer el texto en negrita
                        color: Colors.black,   // Cambiar el color del label
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                SizedBox(
                  width: 285,
                  height: 30,
                  child: TextFormField(
                    controller: _passwordController,
                    validator: (value) => value?.isEmpty ?? true ? 'Ingrese la contraseña' : null,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black, // Aquí puedes poner el color que desees
                          width: 2.0,           // Aquí puedes ajustar el grosor
                        ),
                      ),
                      hintText: 'CONTRASEÑA',
                      hintStyle: TextStyle(
                        fontSize: 16.0,        // Cambiar el tamaño de la fuente
                        fontWeight: FontWeight.w200, // Hacer el texto en negrita
                        color: Colors.black,   // Cambiar el color del label
                      ),
                    ),
                  ),
                ),
                

                SizedBox(height: 25),

                SizedBox(
                  width: 285,
                  height: 30,
                  child: TextFormField(
                    controller: _roleController,
                    validator: (value) => value?.isEmpty ?? true ? 'Ingrese el rol' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black, // Aquí puedes poner el color que desees
                          width: 2.0,           // Aquí puedes ajustar el grosor
                        ),
                      ),
                      hintText: 'ROL',
                      hintStyle: TextStyle(
                        fontSize: 16.0,        // Cambiar el tamaño de la fuente
                        fontWeight: FontWeight.w200, // Hacer el texto en negrita
                        color: Colors.black,   // Cambiar el color del label
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                SizedBox(
                  width: 285,
                  height: 30,
                  child: TextFormField(
                    controller: _branchController,
                    validator: (value) => value?.isEmpty ?? true ? 'Ingrese la sucursal' : null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black, // Aquí puedes poner el color que desees
                          width: 2.0,           // Aquí puedes ajustar el grosor
                        ),
                      ),
                      hintText: 'SUCURSAL',
                      hintStyle: TextStyle(
                        fontSize: 16.0,        // Cambiar el tamaño de la fuente
                        fontWeight: FontWeight.w200, // Hacer el texto en negrita
                        color: Colors.black,   // Cambiar el color del label
                      ),
                    ),
                  ),
                ),
                

                SizedBox(height: 43),

                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      _addEmployee();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE88FAF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("REGISTRAR"),
                  ),
                ),
                
                
              ]
            )
          ,)
        ),
      ),
    );
  }
}