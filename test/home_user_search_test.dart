import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uas/providers/product_provider.dart';
import 'package:uas/services/product_service.dart';
import 'package:uas/screens/user/home_user.dart';
import 'package:uas/widgets/product_card.dart';
import 'package:uas/services/auth_service.dart';
import 'package:uas/providers/auth_provider.dart';

void main() {
  testWidgets('typing in search filters ProductCard count after debounce', (
    tester,
  ) async {
    final service = ProductService();
    final provider = ProductProvider(service);
    // Provide AuthProvider with no pre-registered user (null user is fine)
    final authService = AuthService();
    final authProvider = AuthProvider(authService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>.value(value: provider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: const MaterialApp(home: HomeUser()),
      ),
    );
    print('after pumpWidget');

    // Provider has all items initially
    expect(provider.items.length, service.getAll().length);
    print('after initial provider length expect');
    // There should be at least one ProductCard built in the initial frame
    expect(find.byType(ProductCard), findsWidgets);
    print('found ProductCard initially');

    // Enter a query that should match the 'Celana Jeans' product
    await tester.enterText(find.byType(TextField).first, 'jeans');
    print('entered text');
    await tester.pump();
    // wait for debounce duration (300ms) + pump
    await tester.pump(const Duration(milliseconds: 350));
    print('after debounce pump');

    // After debounce, provider.filteredItems should be filtered and widget tree shows results
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    print('after final pumps');
    expect(provider.filteredItems.isNotEmpty, true);
    expect(find.byType(ProductCard), findsWidgets);
    expect(
      provider.filteredItems.every(
        (p) =>
            p.name.toLowerCase().contains('jeans') ||
            p.description.toLowerCase().contains('jeans') ||
            p.category.toLowerCase().contains('jeans'),
      ),
      true,
    );
  });
}
