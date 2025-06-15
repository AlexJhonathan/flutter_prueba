import 'package:flutter/material.dart';
import 'insumos_por_categoria_screen.dart';
import '../services/supply_category_service.dart';
import 'registrar_insumo_screen.dart'; // Importar la pantalla de registrar insumo

class ListaCategoriasScreen extends StatefulWidget {
  const ListaCategoriasScreen({Key? key}) : super(key: key);

  @override
  State<ListaCategoriasScreen> createState() => _ListaCategoriasScreenState();
}

class _ListaCategoriasScreenState extends State<ListaCategoriasScreen> {
  final SupplyCategoryService _service = SupplyCategoryService();
  List<String> categorias = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final categoriasData = await _service.obtenerCategorias();
      setState(() {
        categorias = categoriasData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Insumos'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cargarCategorias,
                        child: const Text('Intentar de nuevo'),
                      ),
                    ],
                  ),
                )
              : categorias.isEmpty
                  ? const Center(child: Text('No hay categorías disponibles'))
                  : ListView.builder(
                      itemCount: categorias.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              categorias[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InsumosPorCategoriaScreen(
                                    categoria: categorias[index],
                                  ),
                                ),
                              );

                              // Si retornamos un valor, recargar las categorías
                              if (result == true) {
                                cargarCategorias();
                              }
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrarInsumoScreen(),
            ),
          );

          // Si se registra un nuevo insumo, recargar las categorías
          if (result == true) {
            cargarCategorias();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Registrar nuevo insumo',
      ),
    );
  }
}