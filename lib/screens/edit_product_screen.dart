import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  final _categoryController = TextEditingController();
  int _status = 1;
  bool _isLoading = false;

  List<String> _categories = [
    'Desayunos',
    'Tortas (porciones)',
    'Tortas enteras',
    'Minicakes',
    'Para compartir',
    'Bebidas',
    'Frappé',
    'Bagel',
    'Paninis',
    'Chesscakes (porcion)',
    'Chesscakes enteros',
    'Ensaladas',
    'Cuchareables',
    'Otro'
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _selectedCategory = widget.product.category;
    _status = widget.product.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory == 'Otro' ? _categoryController.text : _selectedCategory!,
        status: _status,
      );

      await _productService.updateProduct(updatedProduct);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado con éxito')),
        );
        Navigator.pop(context, true); // true indica que se actualizó exitosamente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addNewCategory() {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        _categories.insert(_categories.length - 1, _categoryController.text);
        _selectedCategory = _categoryController.text;
        _categoryController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del producto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un precio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una categoría';
                        }
                        return null;
                      },
                    ),
                    if (_selectedCategory == 'Otro')
                      Column(
                        children: [
                          TextFormField(
                            controller: _categoryController,
                            decoration: InputDecoration(labelText: 'Nueva Categoría'),
                            validator: (value) => value?.isEmpty ?? true ? 'Ingrese la nueva categoría' : null,
                          ),
                          ElevatedButton(
                            onPressed: _addNewCategory,
                            child: Text('Añadir Nueva Categoría'),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Activo')),
                        DropdownMenuItem(value: 0, child: Text('Inactivo')),
                      ],
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _status = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProduct,
                      child: Text(_isLoading ? 'Actualizando...' : 'Actualizar Producto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}