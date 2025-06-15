import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/table_service.dart';
import 'package:flutter_prueba/pages/auth/login_page.dart';
import 'package:flutter_prueba/pages/cook/cook_page.dart';
import 'package:flutter_prueba/pages/waitress/new_order.dart';
import 'package:flutter_prueba/pages/waitress/order_list.dart';



class WaitressPage extends StatefulWidget {
  final int branchId;

  WaitressPage({required this.branchId});

  @override
  _WaitressPageState createState() => _WaitressPageState();
}

class _WaitressPageState extends State<WaitressPage> {
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
      backgroundColor: const Color.fromARGB(255, 255, 220, 230),
      appBar: AppBar(
        title: const Text('Mesera'),
        backgroundColor: const Color.fromARGB(255, 237, 122, 158),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/loginpage');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            height: 40,
                            child: Text("Eres MESERA", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),),
                          ), 
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Text("Selecciona una mesa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _tables.length,
                          itemBuilder: (context, index) {
                            final table = _tables[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewOrder(
                                    initialSelection: 'Mesa ${table['number']}',
                                    branchId: widget.branchId, // Pasar el branchId
                                  ),
                                ),
                              );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 238, 166, 190),
                                      Color.fromARGB(255, 250, 190, 196)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(2, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Mesa ${table['number']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 237, 122, 158),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long, color: Colors.white),
                          label: const Text(
                            'Ver pedidos',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderList(branchId: widget.branchId),
                            ),
                          );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
