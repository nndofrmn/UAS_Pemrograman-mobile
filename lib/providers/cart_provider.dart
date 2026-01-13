import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;

  CartProvider(this._dbService);

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

  int get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['quantity'] as int)));

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cartItems = await _dbService.getCartItems();
    } catch (e) {
      print('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    try {
      final cartItemId = '${product.id}_${DateTime.now().millisecondsSinceEpoch}';
      await _dbService.addToCart(
        cartItemId,
        product.id,
        product.name,
        product.price,
        quantity,
        product.imagePath,
      );
      await loadCart();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity(String id, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(id);
      } else {
        await _dbService.updateCartItem(id, quantity);
        await loadCart();
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> removeFromCart(String id) async {
    try {
      await _dbService.removeFromCart(id);
      await loadCart();
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _dbService.clearCart();
      await loadCart();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
