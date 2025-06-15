import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  int _status = 1;
  final _productService = ProductService();
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

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final product = Product(
          id: 0, // El ID será asignado por el servidor
          name: _nameController.text,
          price: double.parse(_priceController.text),
          category: _selectedCategory == 'Otro' ? _categoryController.text : _selectedCategory!,
          status: _status,
          createdAt: null,
          updatedAt: null,
          deletedAt: null,
        );
        await _productService.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto añadido exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir el producto: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _editCategory() {
    showDialog(
      context: context,
      builder: (context) {
        final _editCategoryController = TextEditingController(text: 'Otro');
        return AlertDialog(
          title: Text('Editar Categoría'),
          content: TextFormField(
            controller: _editCategoryController,
            decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _categories[_categories.indexOf('Otro')] = _editCategoryController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(title: Text('Añadir Nuevo Producto')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Ingrese el precio' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
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
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _status,
                decoration: InputDecoration(labelText: 'Estado'),
                items: [
                  DropdownMenuItem(value: 1, child: Text('Activo')),
                  DropdownMenuItem(value: 0, child: Text('Inactivo')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addProduct,
                      child: Text('Añadir Producto'),
                    ),
              SizedBox(height: 24),
              Text('Administrar Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                title: Text('Otro'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _editCategory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}