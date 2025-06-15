import 'package:flutter/material.dart';
import 'package:flutter_prueba/pages/admin/branches/branch_edit.dart';
import 'package:flutter_prueba/pages/admin/branches/branch_add.dart';
import 'package:flutter_prueba/services/branch_service.dart';
import 'package:flutter_prueba/models/branch_model.dart';

class BranchList extends StatefulWidget {
  @override
  _BranchListState createState() => _BranchListState();
}

class _BranchListState extends State<BranchList> {

  final _branchService = BranchService();
  bool _isLoading = true;
  List<Branch> _branches = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  void _showEditBranchDialog(Branch branch) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BranchEdit(branch: branch),
    );

    if (result == true) {
      _fetchBranches();
    }
  }

  void _showAddBranchDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BranchAdd(),
    );

    if (result == true) {
      _fetchBranches();
    }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFED7A9E),
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
                    child: Text("SUCURSALES", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                  ), 
                ),
              ),


              Expanded(
                child: ListView.builder(
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    final branch = _branches[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: ListTile(
                          leading: Icon(Icons.home, color: Colors.white),
                          title: Text(
                            branch.name,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            'Dirección: ${branch.address}\nTeléfono: ${branch.phone}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            color: Color.fromARGB(255, 236, 113, 158),
                            onPressed: () {
                              _showEditBranchDialog(branch);
                            },
                          ),
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
          _showAddBranchDialog();
        },
        backgroundColor: Color.fromARGB(255, 236, 113, 158),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}