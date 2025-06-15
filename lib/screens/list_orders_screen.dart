import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import '../services/order_service.dart'; // Servicio para obtener los pedidos


class ListOrdersScreen extends StatefulWidget {
  final int branchId; // ID inicial de la sucursal

  ListOrdersScreen({required this.branchId});

  @override
  _ListOrdersScreenState createState() => _ListOrdersScreenState();
}

class _ListOrdersScreenState extends State<ListOrdersScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _orders = [];
  int _selectedBranchId = 1; // ID inicial de la sucursal (Sucursal 1)

  // Mapa de sucursales
  final Map<int, String> _branches = {
    1: 'Sucursal 1',
    3: 'Tarija Principal',
    4: 'Tarija Parque',
    5: 'La Paz Principal',
    6: 'La Paz Mega',
  };

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.branchId; // Establecer la sucursal inicial
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Obtener los pedidos por sucursal usando el servicio
      final orders = await _orderService.getOrdersByBranch(_selectedBranchId);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los pedidos: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
      ),
      body: Column(
        children: [
          // Filtro de sucursal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<int>(
              value: _selectedBranchId,
              decoration: InputDecoration(
                labelText: 'Seleccionar Sucursal',
                border: OutlineInputBorder(),
              ),
              items: _branches.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBranchId = value;
                  });
                  _fetchOrders(); // Recargar pedidos al cambiar la sucursal
                }
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: TextStyle(color: Colors.red)),
                            ElevatedButton(
                              onPressed: _fetchOrders,
                              child: Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? Center(child: Text('No hay pedidos disponibles'))
                        : ListView.builder(
                            itemCount: _orders.length,
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text('Pedido #${order['id']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Mesa: ${order['tableId'] ?? 'N/A'}'),
                                      Text('Mesero: ${order['waiterId'] ?? 'N/A'}'),
                                      Text('Cocinero: ${order['cookId'] ?? 'N/A'}'),
                                      Text('Fecha: ${_formatDate(order['date'])}'),
                                      Text('Notas: ${order['notes'] ?? 'Sin notas'}'),
                                      Text('Total: \$${order['total']}'),
                                      Text(
                                        'Estado: ${order['status'] == 1 ? 'Activo' : 'Inactivo'}',
                                        style: TextStyle(
                                          color: order['status'] == 1 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(Icons.arrow_forward),
                                  onTap: () {
                                    // Aquí puedes navegar a una pantalla de detalles del pedido si es necesario
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}