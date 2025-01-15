import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController chargeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

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
                child: Text("INICIO SESIÓN", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
              ),
              

              SizedBox(
                width: 285,
                height: 30,
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Aquí puedes poner el color que desees
                        width: 2.0,           // Aquí puedes ajustar el grosor
                      ),
                    ),
                    hintText: 'USUARIO',
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
                child: TextField(
                  controller: emailController,
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
                child: TextField(
                  controller: passwordController,
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
                child: TextField(
                  controller: chargeController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Aquí puedes poner el color que desees
                        width: 2.0,           // Aquí puedes ajustar el grosor
                      ),
                    ),
                    hintText: 'CARGO',
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
                    Navigator.pushNamed(context, '/firstpage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE88FAF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("INICIAR SESIÓN"),
                ),
              ),
              
              
            ]
          )
        ),
      ),
    );
  }
}