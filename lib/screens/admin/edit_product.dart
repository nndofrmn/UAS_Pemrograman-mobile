import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class EditProduct extends StatefulWidget {
  const EditProduct({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  late Product p;
  late TextEditingController _name, _cat, _size, _price, _stock, _desc, _image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    p = ModalRoute.of(context)!.settings.arguments as Product;
    _name = TextEditingController(text: p.name);
    _cat = TextEditingController(text: p.category);
    _size = TextEditingController(text: p.size);
    _price = TextEditingController(text: p.price.toString());
    _stock = TextEditingController(text: p.stock.toString());
    _desc = TextEditingController(text: p.description);
    _image = TextEditingController(text: p.imageUrl ?? '');
    _pickedImagePath = p.imagePath;
  }

  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Barang')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _pickedImagePath != null
                        ? Image.file(
                            File(_pickedImagePath!),
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : (_image.text.isNotEmpty
                              ? Image.network(
                                  _image.text,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: Colors.grey.shade200,
                                    height: 80,
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  height: 80,
                                  child: const Icon(Icons.image),
                                )),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Pilih Gambar'),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              TextFormField(
                controller: _cat,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextFormField(
                controller: _size,
                decoration: const InputDecoration(labelText: 'Ukuran'),
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(
                  labelText: 'Image URL (opsional)',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final updated = Product(
      id: p.id,
      name: _name.text.trim(),
      category: _cat.text.trim(),
      size: _size.text.trim(),
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      price: int.tryParse(_price.text.trim()) ?? 0,
      description: _desc.text.trim(),
      imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
      imagePath: _pickedImagePath,
    );
    context.read<ProductProvider>().update(updated);
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (file != null) {
        setState(() {
          _pickedImagePath = file.path;
        });
      }
    } catch (e) {
      // ignore errors for now
    }
  }
}
