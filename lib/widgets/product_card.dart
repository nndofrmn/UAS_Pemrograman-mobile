import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/formatters.dart';

/// Build a TextSpan that highlights occurrences of [query] inside [text].
TextSpan buildHighlightedTextSpan(
  String text,
  String query,
  TextStyle normalStyle,
  TextStyle highlightStyle,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return TextSpan(text: text, style: normalStyle);

  final lc = text.toLowerCase();
  final children = <TextSpan>[];
  int start = 0;
  int index;

  while ((index = lc.indexOf(q, start)) != -1) {
    if (index > start) {
      children.add(
        TextSpan(text: text.substring(start, index), style: normalStyle),
      );
    }
    children.add(
      TextSpan(
        text: text.substring(index, index + q.length),
        style: highlightStyle,
      ),
    );
    start = index + q.length;
  }

  if (start < text.length) {
    children.add(TextSpan(text: text.substring(start), style: normalStyle));
  }

  return TextSpan(children: children);
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final String? query;

  const ProductCard({super.key, required this.product, this.onTap, this.query});

  @override
  Widget build(BuildContext context) {
    final q = query ?? '';
    final nameStyle = const TextStyle(fontWeight: FontWeight.bold);
    final highlightStyle = nameStyle.copyWith(
      backgroundColor: const Color.fromRGBO(255, 255, 0, 0.6),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area with overlays
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: () {
                      if (product.imagePath != null &&
                          product.imagePath!.isNotEmpty &&
                          !kIsWeb) {
                        return Image.file(
                          File(product.imagePath!),
                          fit: BoxFit.cover,
                        );
                      }
                      if (product.imageUrl != null &&
                          product.imageUrl!.isNotEmpty) {
                        return Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          ),
                        );
                      }
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      );
                    }(),
                  ),

                  // Price badge
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formatIdr(product.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Favorite icon
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: buildHighlightedTextSpan(
                      product.name,
                      q,
                      nameStyle,
                      highlightStyle,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.category} • ${product.size}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatIdr(product.price),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {},
                          ),
                          Text('Stok: ${product.stock}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
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
