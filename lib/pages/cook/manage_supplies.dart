import 'package:flutter/material.dart';
import 'package:flutter_prueba/pages/cook/manage_supplies_list.dart';
import 'package:flutter_prueba/services/supply_category_service.dart';
import 'package:flutter_prueba/pages/cook/manage_supplies_add.dart';

class ManageSupplies extends StatefulWidget {
  const ManageSupplies({Key? key}) : super(key: key);

  @override
  State<ManageSupplies> createState() => _ManageSuppliesState();
}

class _ManageSuppliesState extends State<ManageSupplies> {
  final SupplyCategoryService _service = SupplyCategoryService();
  List<String> categorias = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> _abrirRegistrarInsumoDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ManageSuppliesAdd();
      },
    );

    if (result == true) {
      // Actualizar la lista de insumos/categorías después de registrar exitosamente
      cargarCategorias();
    }
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
      backgroundColor: const Color.fromRGBO(255, 220, 230, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFED7A9E),
        title: const Text('CATEGORÍAS DE INSUMOS', style: TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
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
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: ListView.builder(
                        itemCount: categorias.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 238, 166, 190),
                                  Color.fromARGB(255, 250, 190, 196)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.category, color: Colors.white),
                              title: Text(
                                categorias[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManageSuppliesList(
                                      categoria: categorias[index],
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  cargarCategorias();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirRegistrarInsumoDialog,
        backgroundColor: const Color.fromARGB(255, 236, 113, 158),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Registrar nuevo insumo',
      ),
    );
  }
}
