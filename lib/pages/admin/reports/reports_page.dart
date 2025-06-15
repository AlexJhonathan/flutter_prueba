import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 236, 113, 158),
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
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(
                height: 65,
                child: Text("REPORTES", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
              ),

              
    
            ],
          )
        ),
      ),
    );
  }
}