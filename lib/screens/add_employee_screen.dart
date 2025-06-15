import 'package:flutter/material.dart';
import '../services/user_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  int? _selectedRoleId;
  int _branchId = 1;
  bool _status = false;
  bool _isLoading = false;

  // Opciones para los roles
  final Map<int, String> _roleOptions = {
    1: 'Administrador',
    2: 'Repostera',
    3: 'Mesera',
  };

  // Opciones para las sucursales
  final Map<int, String> _branchOptions = {
    1: 'General',
    3: 'Tarija Principal',
    4: 'Tarija Parque',
    5: 'La Paz Principal',
    6: 'La Paz Mega',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el email';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un rol')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _userService.addUser(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _selectedRoleId!,
        _branchId,
        _status,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.error == null || response.error!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empleado añadido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Empleado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validateField(value, 'el nombre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => _validateField(value, 'la contraseña'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedRoleId,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                items: _roleOptions.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoleId = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un rol' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _branchId,
                decoration: const InputDecoration(
                  labelText: 'Sucursal',
                  border: OutlineInputBorder(),
                ),
                items: _branchOptions.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _branchId = value;
                    });
                  }
                },
                validator: (value) => value == null ? 'Seleccione una sucursal' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponibilidad'),
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _addEmployee,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Añadir Empleado'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}