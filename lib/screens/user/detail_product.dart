import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../utils/formatters.dart';

class DetailProduct extends StatelessWidget {
  const DetailProduct({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: () {
                  if (product.imagePath != null &&
                      product.imagePath!.isNotEmpty &&
                      !kIsWeb) {
                    return Image.file(
                      File(product.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    );
                  }
                  if (product.imageUrl != null &&
                      product.imageUrl!.isNotEmpty) {
                    return Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    );
                  }
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 72),
                  );
                }(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Kategori: ${product.category} • Size: ${product.size}'),
            const SizedBox(height: 8),
            Text(
              'Harga: ${formatIdr(product.price)}',
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok: ${product.stock}',
              style: TextStyle(
                color: product.stock > 0 ? Colors.black : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}
