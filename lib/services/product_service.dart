import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  final AuthService _authService;
  static const String _baseUrl = 'http://localhost:3001/api/products';

  ProductService(this._authService);

  /// Get all products
  Future<List<Product>> getAll() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Get all products error: $e');
    }
    return [];
  }

  /// Get product by ID
  Future<Product?> getById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      }
    } catch (e) {
      print('Get product by id error: $e');
    }
    return null;
  }

  /// Search products
  Future<List<Product>> search(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Search products error: $e');
    }
    return [];
  }

  /// Create new product (admin only)
  Future<Product?> create(Product product) async {
    if (_authService.token == null) return null;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'name': product.name,
          'category': product.category,
          'size': product.size,
          'stock': product.stock,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      }
    } catch (e) {
      print('Create product error: $e');
    }
    return null;
  }

  /// Update product (admin only)
  Future<bool> update(Product product) async {
    if (_authService.token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${product.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'name': product.name,
          'category': product.category,
          'size': product.size,
          'stock': product.stock,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update product error: $e');
    }
    return false;
  }

  /// Delete product (admin only)
  Future<bool> delete(String id) async {
    if (_authService.token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete product error: $e');
    }
    return false;
  }
}
