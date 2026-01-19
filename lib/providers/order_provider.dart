import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;
  final AuthService _authService;
  List<Order> _orders = [];
  bool _isLoading = false;
  String _error = '';

  OrderProvider(this._orderService, this._authService);

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadUserOrders() async {
    if (_authService.token == null) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders(_authService.token!);
    } catch (e) {
      _error = e.toString();
      print('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> createOrder(List<Map<String, dynamic>> cartItems) async {
    if (_authService.token == null) return null;

    try {
      final order = await _orderService.createOrder(cartItems, _authService.token!);
      if (order != null) {
        await loadUserOrders(); // Refresh orders list
      }
      return order;
    } catch (e) {
      _error = e.toString();
      print('Error creating order: $e');
      notifyListeners();
      return null;
    }
  }

  Future<Order?> getOrderById(String id) async {
    if (_authService.token == null) return null;

    try {
      return await _orderService.getOrderById(id, _authService.token!);
    } catch (e) {
      _error = e.toString();
      print('Error getting order: $e');
      return null;
    }
  }

  Future<bool> cancelOrder(String id) async {
    if (_authService.token == null) return false;

    try {
      final success = await _orderService.cancelOrder(id, _authService.token!);
      if (success) {
        await loadUserOrders(); // Refresh orders list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      print('Error cancelling order: $e');
      return false;
    }
  }
}
