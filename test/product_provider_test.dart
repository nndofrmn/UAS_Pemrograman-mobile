import 'package:flutter_test/flutter_test.dart';
import 'package:uas/providers/product_provider.dart';
import 'package:uas/services/product_service.dart';

void main() {
  group('ProductProvider.filteredItems', () {
    late ProductService service;
    late ProductProvider provider;

    setUp(() {
      service = ProductService();
      provider = ProductProvider(service);
    });

    test('returns all items when query is empty', () {
      expect(provider.filteredItems.length, service.getAll().length);
    });

    test('filters by name, description or category (case-insensitive)', () {
      provider.setQuery('jeans');
      final results = provider.filteredItems;
      expect(results.isNotEmpty, true);
      expect(
        results.every((p) {
          final q = 'jeans';
          return p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q);
        }),
        true,
      );
    });

    test('clearQuery resets filter', () {
      provider.setQuery('jeans');
      expect(provider.query.isNotEmpty, true);
      provider.clearQuery();
      expect(provider.query, '');
      expect(provider.filteredItems.length, service.getAll().length);
    });
  });
}
