import 'package:flutter/material.dart';
import '../services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  OrderProvider(this._dbService);

  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _dbService.getUserOrders(userId);
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrder(String userId, List<Map<String, dynamic>> cartItems, int totalPrice) async {
    try {
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      await _dbService.insertOrder(
        orderId,
        userId,
        totalPrice,
        'pending',
        DateTime.now().toIso8601String(),
        cartItems.toString(),
      );
      await loadUserOrders(userId);
    } catch (e) {
      print('Error creating order: $e');
    }
  }
}
