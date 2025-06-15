import 'package:flutter/material.dart';
import 'package:flutter_prueba/services/product_service.dart';
import 'package:flutter_prueba/models/product_model.dart';

class ProductEdit extends StatefulWidget {
  final Product product;

  const ProductEdit({required this.product});

  @override
  _ProductEditState createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  int _status = 1;
  final _productService = ProductService();
  bool _isLoading = false;
  String? _selectedCategory;
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _categoryController = TextEditingController();
    _status = widget.product.status ?? 1;

    if (_categories.contains(widget.product.category)) {
      _selectedCategory = widget.product.category;
    } else {
      _selectedCategory = 'Otro';
      _categoryController.text = widget.product.category ?? '';
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedProduct = Product(
          id: widget.product.id,
          name: _nameController.text,
          price: double.parse(_priceController.text),
          category: _selectedCategory == 'Otro' ? _categoryController.text : _selectedCategory!,
          status: _status,
          createdAt: widget.product.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: widget.product.deletedAt,
        );
        await _productService.updateProduct(updatedProduct);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto actualizado exitosamente')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 220, 230),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header rosa fuerte
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 236, 113, 158),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Editar Producto",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Nombre del Producto',
                          hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: Colors.black),
                          contentPadding: EdgeInsets.only(bottom: -10),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                        ),
                        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Precio',
                          hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: Colors.black),
                          contentPadding: EdgeInsets.only(bottom: -10),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                        ),
                        validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'Categoría',
                          contentPadding: EdgeInsets.only(bottom: -10),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        validator: (value) => value == null ? 'Seleccione una categoría' : null,
                      ),
                    ),
                    if (_selectedCategory == 'Otro')
                      Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            hintText: 'Nueva Categoría',
                            contentPadding: EdgeInsets.only(bottom: -10),
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                          ),
                          validator: (value) => value!.isEmpty ? "Ingrese la nueva categoría" : null,
                        ),
                      ),
                    SwitchListTile(
                      title: Text('Estado'),
                      subtitle: Text(_status == 1 ? 'Activo' : 'Inactivo'),
                      value: _status == 1,
                      activeColor: Colors.green,
                      onChanged: (value) => setState(() => _status = value ? 1 : 0),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 16, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProduct,
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 236, 113, 158)),
                    child: _isLoading
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Actualizar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
