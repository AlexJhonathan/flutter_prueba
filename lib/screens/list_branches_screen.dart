import 'package:flutter/material.dart';
import '../services/branch_service.dart';
import '../models/branch_model.dart';
import 'edit_branch_screen.dart';
import 'list_tables_screen.dart'; // Nueva pantalla para listar mesas

class ListBranchesScreen extends StatefulWidget {
  @override
  _ListBranchesScreenState createState() => _ListBranchesScreenState();
}

class _ListBranchesScreenState extends State<ListBranchesScreen> {
  final _branchService = BranchService();
  bool _isLoading = true;
  List<Branch> _branches = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final branches = await _branchService.getBranches();
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBranch(int branchId) async {
    try {
      await _branchService.deleteBranch(branchId);
      setState(() {
        _branches.removeWhere((branch) => branch.id == branchId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sucursal eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la sucursal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listar Sucursales'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : ListView.builder(
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    final branch = _branches[index];
                    return ListTile(
                      title: Text(branch.name),
                      subtitle: Text('Dirección: ${branch.address}\nTeléfono: ${branch.phone}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBranchScreen(branch: branch),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmar eliminación'),
                                  content: Text('¿Estás seguro de que deseas eliminar esta sucursal?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                _deleteBranch(branch.id!);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.table_chart),
                            color: Colors.green,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListTablesScreen(branchId: branch.id!),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}