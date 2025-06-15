import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/auth_service.dart';
import 'package:flutter_prueba/pages/waitress/waitress_page.dart';
import 'package:flutter_prueba/pages/cook/cook_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

 
  Future<void> _login() async {
    print("estoy aqui");
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final response = await _authService.login(
        context,
        _emailController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (response.error.isEmpty) {
        switch (response.role) {
          case 1:
            Navigator.pushReplacementNamed(context, '/adminpage');
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CookPage(branchId: response.branchId),
              ),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WaitressPage(branchId: response.branchId),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Rol desconocido')),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error)),
        );
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Image.asset(
                            'lib/images/thecakee.png',
                            width: 130,
                            height: 200,
                          ),
                          SizedBox(height: 0),
                          
                          Text(
                            "INICIO SESIÓN",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                          ),
                          SizedBox(height: 40),

                          SizedBox(
                            width: 285,
                            child: TextFormField(
                              controller: _emailController,
                              validator: (value) => value?.isEmpty ?? true ? 'Ingrese el usuario' : null,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                                ),
                                hintText: 'EMAIL',
                                hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),

                          SizedBox(
                            width: 285,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) => value?.isEmpty ?? true ? 'Ingrese la contraseña' : null,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                                ),
                                hintText: 'CONTRASEÑA',
                                hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 43),

                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE88FAF),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("INICIAR SESIÓN"),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


}