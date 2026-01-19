import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cat = TextEditingController();
  final _size = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _pickedImagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang')),
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(
                  labelText: 'Image URL (opsional)',
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _onAdd, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onAdd() async {
    final p = Product(
      id: '', // Backend will generate ID
      name: _name.text.trim(),
      category: _cat.text.trim(),
      size: _size.text.trim(),
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      price: int.tryParse(_price.text.trim()) ?? 0,
      description: _desc.text.trim(),
      imageUrl: _image.text.trim().isEmpty ? null : _image.text.trim(),
      imagePath: _pickedImagePath,
    );

    final success = await context.read<ProductProvider>().addProduct(p);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambah produk')),
      );
    }
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
