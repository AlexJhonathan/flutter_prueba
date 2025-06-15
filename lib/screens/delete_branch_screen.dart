import 'package:flutter/material.dart';
import '../services/branch_service.dart';

class DeleteBranchScreen extends StatefulWidget {
  final int branchId;

  DeleteBranchScreen({required this.branchId});

  @override
  _DeleteBranchScreenState createState() => _DeleteBranchScreenState();
}

class _DeleteBranchScreenState extends State<DeleteBranchScreen> {
  final _branchService = BranchService();
  bool _isLoading = false;
  String _error = '';

  Future<void> _deleteBranch() async {
    setState(() => _isLoading = true);

    try {
      await _branchService.deleteBranch(widget.branchId);
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
        title: Text('Eliminar Sucursal'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Está seguro de que desea eliminar esta sucursal?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _deleteBranch,
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