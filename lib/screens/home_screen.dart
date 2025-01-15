import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import 'add_branch_screen.dart'; // Import AddBranchScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _branchIDController = TextEditingController();
  final _statusController = TextEditingController();
  final _menuService = MenuService();
  bool _isLoading = false;

  Future<void> _createMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final response = await _menuService.createMenu(
        _nameController.text,
        int.parse(_branchIDController.text),
        int.parse(_statusController.text),
      );

      setState(() => _isLoading = false);

      if (response.error.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menu created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Menu')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Enter name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _branchIDController,
                decoration: InputDecoration(labelText: 'Branch ID'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Enter branch ID' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Enter status' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _createMenu,
                          child: Text('Create'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddBranchScreen()),
                            );
                          },
                          child: Text('Add Branch'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}