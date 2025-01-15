import 'package:flutter/material.dart';


class FisrtPage extends StatelessWidget {
  const FisrtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("1st Page")),
      drawer: Drawer(
        
        backgroundColor: Colors.cyan,
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(
                Icons.favorite,
                size: 40,
              )
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("H O M E"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/homepage');
              }
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("S E T T I N G S"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settingspage');
              }
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("login"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/loginpage');
              }
            ),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("register"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/registerpage');
              }
            )
          ]
        )
      ),
    );
  }
}