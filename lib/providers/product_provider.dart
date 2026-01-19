import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service;
  List<Product> _items = [];
  bool _isLoading = false;
  String _error = '';
  String _query = '';
  String _category = 'All';

  ProductProvider(this._service) {
    loadProducts();
  }

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<String> get categories {
    final set = <String>{'All'};
    for (final p in _items) {
      set.add(p.category);
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  /// Products filtered by current query (name, description, category)
  List<Product> get filteredItems {
    final q = _query.trim().toLowerCase();
    return _items.where((p) {
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

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _items = await _service.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _items = await _service.search(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      final result = await _service.create(product);
      if (result != null) {
        await loadProducts(); // Refresh the list
        return true;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final success = await _service.update(product);
      if (success) {
        await loadProducts(); // Refresh the list
        return true;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final success = await _service.delete(id);
      if (success) {
        await loadProducts(); // Refresh the list
        return true;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return false;
  }

  Future<Product?> getProductById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
