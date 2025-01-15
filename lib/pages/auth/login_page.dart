import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String username = 'Alex';
  final password = '1234';

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool validate(String username, final password){
    if(username == this.username && password == this.password){
      return true;
    }else{
      return false;
    }
  }

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
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    hintText: 'USUARIO',
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
                height: 30,
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2.0,           
                      ),
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

              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    if(validate(usernameController.text, passwordController.text)){
                      Navigator.pushNamed(context, '/homepage');
                    }else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Usuario o contraseña incorrectos"),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cerrar"),
                              )
                            ],
                          );
                        }
                      );
                    }
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