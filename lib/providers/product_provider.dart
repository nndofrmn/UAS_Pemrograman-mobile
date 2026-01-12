import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service;
  String _query = '';
  String _category = 'All';

  ProductProvider(this._service);

  List<Product> get items => _service.getAll();

  List<String> get categories {
    final set = <String>{'All'};
    for (final p in items) {
      set.add(p.category);
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  /// Products filtered by current query (name, description, category)
  List<Product> get filteredItems {
    final q = _query.trim().toLowerCase();
    return items.where((p) {
      if (_category != 'All' && p.category != _category) return false;
      if (q.isEmpty) return true;
      final name = p.name.toLowerCase();
      final desc = p.description.toLowerCase();
      final cat = p.category.toLowerCase();
      return name.contains(q) || desc.contains(q) || cat.contains(q);
    }).toList();
  }

  String get query => _query;
  String get category => _category;

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void clearQuery() {
    _query = '';
    notifyListeners();
  }

  void setCategory(String c) {
    _category = c;
    notifyListeners();
  }

  void clearCategory() {
    _category = 'All';
    notifyListeners();
  }

  void add(Product p) {
    _service.add(p);
    notifyListeners();
  }

  void update(Product p) {
    _service.update(p);
    notifyListeners();
  }

  void delete(String id) {
    _service.delete(id);
    notifyListeners();
  }

  void updateStock(String id, int delta) {
    _service.updateStock(id, delta);
    notifyListeners();
  }
}
