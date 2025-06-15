import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'list_branches_screen.dart'; // Importar la pantalla de listar sucursales
//import 'add_branch_screen.dart'; // Importar la pantalla de añadir branch
import 'list_menus_screen.dart'; // Importar la pantalla de listar menús
import 'list_users_screen.dart'; // Importar la pantalla de listar usuarios
import 'list_supplies_screen.dart'; // Importar la pantalla de listar insumos
import 'list_orders_screen.dart'; // Importar la pantalla de listar pedidos

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text('Administrador'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListOrdersScreen(branchId: 1), // Navegar a la pantalla de listar pedidos
                  ),
                );
              },
              child: Text('Ventas'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListMenusScreen()), // Navegar a la pantalla de listar menús
                );
              },
              child: Text('Menú'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListBranchesScreen()), // Navegar a la pantalla de listar sucursales
                );
              },
              child: Text('Listar Sucursales'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListUsersScreen()), // Navegar a la pantalla de listar usuarios
                );
              },
              child: Text('Personal'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Acción para el botón Reportes
              },
              child: Text('Reportes'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListSuppliesScreen()), // Navegar a la pantalla de listar insumos
                );
              },
              child: Text('Ver Insumos'),
            ),
          ],
        ),
      ),
    );
  }
}