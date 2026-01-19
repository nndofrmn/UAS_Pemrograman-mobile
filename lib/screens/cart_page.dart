import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/formatters.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartItems = cartProvider.cartItems;
    final totalPrice = cartProvider.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _clearCart(context),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang kosong',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tambahkan produk dari halaman utama',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, item, cartProvider);
                    },
                  ),
                ),
                _buildOrderSummary(context, totalPrice, cartItems),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item, CartProvider cartProvider) {
    final productId = item['productId'] as String;
    final productName = item['name'] as String;
    final price = item['price'] as int;
    final quantity = item['quantity'] as int;
    final imagePath = item['imagePath'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePath != null && imagePath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.image),
                      ),
                    )
                  : const Icon(Icons.image),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatIdr(price),
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => cartProvider.updateQuantity(productId, quantity - 1),
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => cartProvider.updateQuantity(productId, quantity + 1),
                ),
              ],
            ),
            // Remove item
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => cartProvider.removeFromCart(productId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, int totalPrice, List<Map<String, dynamic>> cartItems) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                formatIdr(totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : () => _placeOrder(context, cartItems, totalPrice),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Buat Pesanan'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Apakah Anda yakin ingin mengosongkan keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, List<Map<String, dynamic>> cartItems, int totalPrice) async {
    setState(() => _isPlacingOrder = true);

    try {
      // Convert cart items to order format
      final orderItems = cartItems.map((item) {
        return {
          'productId': item['productId'],
          'name': item['name'],
          'quantity': item['quantity'],
          'price': item['price'],
        };
      }).toList();

      final orderProvider = context.read<OrderProvider>();
      final cartProvider = context.read<CartProvider>();

      final order = await orderProvider.createOrder(orderItems);

      if (!mounted) return;

      if (order != null) {
        // Clear cart after successful order
        cartProvider.clearCart();

        if (!mounted) return;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!')),
        );

        // Navigate to orders page
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/orders');
      } else {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat pesanan')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }
}
