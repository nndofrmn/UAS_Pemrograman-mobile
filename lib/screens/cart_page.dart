import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: const Center(
        child: Text('Keranjang kosong — tambahkan produk dari Home'),
      ),
    );
  }
}
