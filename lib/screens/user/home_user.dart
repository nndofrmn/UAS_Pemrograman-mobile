import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/modern_widgets.dart';
import '../../widgets/loading_widgets.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v, void Function(String) apply) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => apply(v));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.filteredItems;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    const primaryColor = Color(0xFF6366F1);
    const accentColor = Color(0xFF8B5CF6);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 140,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Halo, ${user?.name.split(' ').first}! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Temukan pakaian pilihan Anda',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'logout') {
                        context.read<AuthProvider>().signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      } else if (value == 'orders') {
                        Navigator.pushNamed(context, '/orders');
                      } else if (value == 'profile') {
                        Navigator.pushNamed(context, '/profile');
                      } else if (value == 'settings') {
                        Navigator.pushNamed(context, '/settings');
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          user?.name ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'orders',
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long_rounded, size: 18),
                            SizedBox(width: 12),
                            Text('Orders'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_rounded, size: 18),
                            SizedBox(width: 12),
                            Text('Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings_rounded, size: 18),
                            SizedBox(width: 12),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text(
                          'Logout',
                          style: TextStyle(color: const Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        (user?.name.isNotEmpty == true) ? user!.name[0] : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => _onSearchChanged(v, provider.setQuery),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            provider.clearQuery();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),

          // Categories (Sticky)
          if (provider.categories.length > 1)
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoriesDelegate(provider),
            ),

          // Products Grid
          if (products.isEmpty)
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: EmptyStateWidget(
                  message: 'Produk tidak ditemukan',
                  subMessage: 'Coba ubah pencarian atau kategori Anda',
                  icon: Icons.search_off_rounded,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: product,
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: const SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.shopping_cart_rounded),
        label: const Text('Keranjang'),
      ),
    );
  }
}

// Categories Delegate
class _CategoriesDelegate extends SliverPersistentHeaderDelegate {
  final ProductProvider provider;

  _CategoriesDelegate(this.provider);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: provider.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final category = provider.categories[index];
            final isSelected = provider.category == category;
            return CategoryChip(
              label: category,
              isSelected: isSelected,
              onTap: () => provider.setCategory(category),
            );
          },
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(_CategoriesDelegate oldDelegate) => true;
}
