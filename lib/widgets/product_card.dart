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

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final String? query;

  const ProductCard({super.key, required this.product, this.onTap, this.query});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.query ?? '';
    final nameStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Color(0xFF1E293B),
    );
    final highlightStyle = nameStyle.copyWith(
      backgroundColor: const Color.fromRGBO(255, 193, 7, 0.3),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image area with overlays
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: () {
                        if (widget.product.imagePath != null &&
                            widget.product.imagePath!.isNotEmpty &&
                            !kIsWeb) {
                          return Image.file(
                            File(widget.product.imagePath!),
                            fit: BoxFit.cover,
                          );
                        }
                        if (widget.product.imageUrl != null &&
                            widget.product.imageUrl!.isNotEmpty) {
                          return Image.network(
                            widget.product.imageUrl!,
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
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          formatIdr(widget.product.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Favorite icon
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? const Color(0xFFEF4444) : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Stock badge
                  if (widget.product.stock < 5)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Terbatas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: buildHighlightedTextSpan(
                        widget.product.name,
                        q,
                        nameStyle,
                        highlightStyle,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.product.category} • ${widget.product.size}',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Stok: ${widget.product.stock}',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
