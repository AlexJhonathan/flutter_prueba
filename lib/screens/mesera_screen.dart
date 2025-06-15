import 'package:flutter/material.dart';
import '../services/table_service.dart';
import 'login_screen.dart';
import 'repostera_screen.dart';
import 'pedidos1_screen.dart';
import 'ver_pedidos_mesera_screen.dart'; // Importar la nueva pantalla

class MeseraScreen extends StatefulWidget {
  final int branchId; // Recibe el ID de la sucursal

  MeseraScreen({required this.branchId});

  @override
  _MeseraScreenState createState() => _MeseraScreenState();
}

class _MeseraScreenState extends State<MeseraScreen> {
  final TableService _tableService = TableService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _tables = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    try {
      final tables = await _tableService.getTablesByBranch(widget.branchId);
      setState(() {
        // Filtrar solo las mesas activas
        _tables = tables.where((table) => table['status'] == true).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las mesas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text('Mesera'),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    // Botón para cambiar a la pantalla de Repostera
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReposteraScreen(branchId: widget.branchId),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Mesera'),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.all(16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: _tables.length,
                        itemBuilder: (context, index) {
                          final table = _tables[index];
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Pedidos1Screen(
                                    initialSelection: 'Mesa ${table['number']}',
                                    branchId: widget.branchId, // Pasar el branchId
                                  ),
                                ),
                              );
                            },
                            child: Text('Mesa ${table['number']}'),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navegar a la pantalla VerPedidosMeseraScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerPedidosMeseraScreen(branchId: widget.branchId),
                            ),
                          );
                        },
                        child: Text('Ver pedidos'),
                      ),
                    ),
                  ],
                ),
    );
  }
}