import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color.fromARGB(255, 237, 122, 158),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
        child: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pop(context);
          },
        ),)
        
      ],
    ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0),

          child: ListView(
            children: [

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: SizedBox(
                    height: 65,
                    child: Text(
                      "ADMIN", 
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,  // Color del texto
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.4),
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ), 
                ),
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 12, right: 0, bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/personallist');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE88FAF), Color(0xFFFC95A1)], // Colores de gradiente
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text(
                                    "PERSONAL",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 0, right: 12, bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/reportspage');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE88FAF), Color(0xFFFC95A1)], // Colores de gradiente
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text(
                                    "REPORTES",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                        
                    ),
                  )
                ],
              ),
              
              

              SizedBox(height: 30),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 12, right: 0, bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/supplieslist');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE88FAF), Color(0xFFFC95A1)], // Colores de gradiente
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text(
                                    "INSUMOS",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 0, right: 12, bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/menuslist');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE88FAF), Color(0xFFFC95A1)], // Colores de gradiente
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text("MENÚ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white)),
                                ),
                              ],   
                            )
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              

              SizedBox(height: 30),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 12, right: 0, bottom: 15),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/branchlist');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 100,
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE88FAF), Color(0xFFFC95A1)], // Colores de gradiente
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4), // Desplazamiento de la sombra
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text("SUCURSALES", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.white)),
                                ),
                              ],   
                            )
                          ),
                        ),
                      ),
                      
                    ),
                  ),

                ],
              ),

              
    
            ],
          )
        ),
      ),
    );
  }
}