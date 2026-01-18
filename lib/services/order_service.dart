import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';

class OrderService {
  final String baseUrl = 'http://localhost:3000/api';

  /// Create order baru
  Future<Order?> createOrder(List<Map<String, dynamic>> items, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'items': items}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data['order']);
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Get orders user
  Future<List<Order>> getUserOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// Get order detail
  Future<Order?> getOrderById(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String id, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$id/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }
}
