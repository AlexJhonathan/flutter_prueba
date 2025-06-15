import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'edit_user_screen.dart';
import 'add_employee_screen.dart';

class ListUsersScreen extends StatefulWidget {
  @override
  _ListUsersScreenState createState() => _ListUsersScreenState();
}

class _ListUsersScreenState extends State<ListUsersScreen> {
  final _userService = UserService();
  bool _isLoading = true;
  List<User> _users = [];
  String _error = '';
  int? _selectedBranch;

  // Mapa para los nombres de las sucursales
  final Map<int, String> _branchNames = {
    1: 'General',
    3: 'Tarija Principal',
    4: 'Carla Tarija Parque',
    5: 'La Paz Principal',
    6: 'La Paz Mega',
  };

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
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
        return 'Repostera';
      case 3:
        return 'Mesera';
      default:
        return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Usuarios'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Column(
                  children: [
                    // Filtro por sucursal
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<int?>(
                        value: _selectedBranch,
                        hint: Text('Seleccionar Sucursal'),
                        items: [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          ..._branchNames.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filterUsersByBranch(_users, _selectedBranch).length,
                        itemBuilder: (context, index) {
                          final user = _filterUsersByBranch(_users, _selectedBranch)[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(user.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${user.email}'),
                                  Text('Sucursal: ${_branchNames[user.branchId] ?? 'Desconocida'}'),
                                  Text('Rol: ${_getRoleText(user.role)}'),
                                  Row(
                                    children: [
                                      Text('Estado: '),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: user.status ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          user.status ? 'Disponible' : 'No disponible',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Switch para cambiar el estado del usuario
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
                                  ),
                                  // Botón para editar el usuario
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditUserScreen(user: user),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _fetchUsers();
                                        }
                                      });
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEmployeeScreen()),
          ).then((value) {
            if (value == true) {
              _fetchUsers();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}