import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        title: Text("Inicio"),
        backgroundColor: Color(0xFFE88FAF),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(
                height: 70,
                child: Text("INICIO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/waitresspage');
                },
                child: Container(
                  width: 250,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFE88FAF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 25,
                          width: 118,
                          child: Text(
                            "MESERA/O",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                          ),
                        ),
                        Image.asset(
                          'lib/images/mesero.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 35),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/cookpage');
                },
                child: Container(
                  width: 250,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFE88FAF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 25,
                          width: 137,
                          child: Text("COCINERA/O", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                        ),
                        Image.asset(
                          'lib/images/sombrero.png',
                          width: 40,
                          height: 40,
                        ),
                      ],   
                    )
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/registerpage');
                },
                child: Container(
                  width: 250,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFE88FAF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 25,
                          width: 137,
                          child: Text("COCINERA/O", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                        ),
                        Image.asset(
                          'lib/images/sombrero.png',
                          width: 40,
                          height: 40,
                        ),
                      ],   
                    )
                  ),
                ),
              ),
    
            ],
          )
        ),
      ),
    );
  }
}