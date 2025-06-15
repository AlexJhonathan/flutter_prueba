import 'package:flutter/material.dart';
import '../services/user_service.dart';

class DeleteUserScreen extends StatefulWidget {
  final int userId;

  DeleteUserScreen({required this.userId});

  @override
  _DeleteUserScreenState createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final _userService = UserService();
  bool _isLoading = false;
  String _error = '';

  Future<void> _deleteUser() async {
    setState(() => _isLoading = true);

    try {
      await _userService.deleteUser(widget.userId);
      Navigator.pop(context, true); // Volver a la pantalla anterior con éxito
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eliminar Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Está seguro de que desea eliminar este usuario?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _deleteUser,
                    child: Text('Eliminar'),
                    
                  ),
            SizedBox(height: 16),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}