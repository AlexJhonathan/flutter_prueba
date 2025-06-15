import 'package:flutter/material.dart';
import 'package:flutter_prueba/pages/admin/personal/personal_edit.dart';
import 'package:flutter_prueba/pages/admin/personal/personal_add.dart';
import 'package:flutter_prueba/services/user_service.dart';
import 'package:flutter_prueba/models/user_model.dart';

class PersonalList extends StatefulWidget {
  @override
  _PersonalListState createState() => _PersonalListState();
}

class _PersonalListState extends State<PersonalList> {

  final _userService = UserService();
  bool _isLoading = true;
  List<User> _users = [];
  String _error = '';
  int? _selectedBranch;

  @override
  void initState() {
    
    super.initState();
    _fetchUsers();
  }

  void _showAddPersonalDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PersonalAdd(),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  void _showEditPersonalDialog(User user) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PersonalEdit(user: user),
    );

    if (result == true) {
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    print("Aqui estoy");
    try {
      final users = await _userService.getUsers();
      setState(() {
        
        _users = users;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<User> _filterUsersByBranch(List<User> users, int? branchId) {
    if (branchId == null) {
      return users;
    }
    return users.where((user) => user.branchId == branchId).toList();
  }

  String _getRoleText(int role) {
    switch (role) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Empleado';
      case 3:
        return 'Cliente';
      default:
        return 'Desconocido';
    }
  }

  Color _getRoleColor(int role) {
    switch (role) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }


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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 40,
                    child: Text("PERSONAL", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                  ), 
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 236, 113, 158), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedBranch,
                      isExpanded: true,
                      hint: Text('Seleccionar Sucursal'),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(value: 3, child: Text('Tarija Principal')),
                        DropdownMenuItem(value: 4, child: Text('Tarija Parque')),
                        DropdownMenuItem(value: 5, child: Text('La Paz Principal')),
                        DropdownMenuItem(value: 6, child: Text('La Paz Mega')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBranch = value;
                        });
                      },
                    ),
                  ),
                ),
              ),


              Expanded(
                child: ListView.builder(
                  itemCount: _filterUsersByBranch(_users, _selectedBranch).length,
                  itemBuilder: (context, index) {
                    final user = _filterUsersByBranch(_users, _selectedBranch)[index];
                    return Container(
                      
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 238, 166, 190), Color.fromARGB(255, 250, 190, 196)],
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
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: ListTile(
                        
                        title: Text(user.name),
                        subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${user.email}'),
                          Text('Sucursal: ${user.branchId}'),
                          Text('Rol: ${_getRoleText(user.role)}'),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 0),
                            child: Row(
                              children: [
                                
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: user.status ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.status ? 'Disponible' : 'No disponible',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ]
                            ),
                          ),
                          
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: user.status,
                            onChanged: (bool value) async {
                            try {
                              await _userService.updateUser(
                                user.id,
                                user.name,
                                user.email,
                                user.password,
                                user.role,
                                user.branchId,
                                value,
                              );
                              _fetchUsers(); // Recargar la lista después de actualizar
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al actualizar el estado')),
                              );
                            }
                          },
                          activeColor: Color.fromARGB(255, 236, 101, 151),
                          activeTrackColor: const Color.fromARGB(255, 242, 152, 182),
                          inactiveThumbColor: const Color.fromARGB(255, 189, 189, 189),
                          inactiveTrackColor: Colors.grey.shade300
                          ),
                        IconButton(
                              icon: Icon(Icons.edit),
                                color: Color.fromARGB(255, 236, 113, 158),
                                onPressed: () {
                                  _showEditPersonalDialog(user);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPersonalDialog();
        },
        backgroundColor: Color.fromARGB(255, 236, 113, 158),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}