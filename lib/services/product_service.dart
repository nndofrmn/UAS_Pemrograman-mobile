import '../models/product_model.dart';

/// In-memory product service with simple CRUD for demo/UAS.
class ProductService {
  final List<Product> _items = [
    Product(
      id: 'p1',
      name: 'Kaos Vintage',
      category: 'Kaos',
      size: 'M',
      stock: 5,
      price: 70000,
      description: 'Kaos vintage berkualitas',
      imageUrl: 'https://picsum.photos/seed/p1/400/400',
    ),
    Product(
      id: 'p2',
      name: 'Jaket Denim',
      category: 'Jaket',
      size: 'L',
      stock: 2,
      price: 150000,
      description: 'Jaket denim second but in great condition',
      imageUrl: 'https://picsum.photos/seed/p2/400/400',
    ),
    Product(
      id: 'p3',
      name: 'Celana Chino',
      category: 'Celana',
      size: 'M',
      stock: 8,
      price: 90000,
      description: 'Celana chino warna khaki, nyaman dipakai sehari-hari',
      imageUrl: 'https://picsum.photos/seed/p3/400/400',
    ),
    Product(
      id: 'p4',
      name: 'Sweater Rajut',
      category: 'Sweater',
      size: 'L',
      stock: 4,
      price: 120000,
      description: 'Sweater rajut hangat, cocok untuk cuaca dingin',
      imageUrl: 'https://picsum.photos/seed/p4/400/400',
    ),
    Product(
      id: 'p5',
      name: 'Kemeja Flanel',
      category: 'Kemeja',
      size: 'XL',
      stock: 6,
      price: 110000,
      description: 'Kemeja flanel motif kotak-kotak, kondisi bagus',
      imageUrl: 'https://picsum.photos/seed/p5/400/400',
    ),
    Product(
      id: 'p6',
      name: 'Rok Plisket',
      category: 'Rok',
      size: 'S',
      stock: 3,
      price: 80000,
      description: 'Rok plisket feminin, cocok untuk berbagai acara',
      imageUrl: 'https://picsum.photos/seed/p6/400/400',
    ),
    Product(
      id: 'p7',
      name: 'Top Tank',
      category: 'Kaos',
      size: 'S',
      stock: 10,
      price: 45000,
      description: 'Tank top simpel, cocok untuk layering',
      imageUrl: 'https://picsum.photos/seed/p7/400/400',
    ),
    Product(
      id: 'p8',
      name: 'Blazer Bekas',
      category: 'Jaket',
      size: 'M',
      stock: 1,
      price: 200000,
      description: 'Blazer formal second, kondisi rapi',
      imageUrl: 'https://picsum.photos/seed/p8/400/400',
    ),
    Product(
      id: 'p9',
      name: 'Hoodie Oversize',
      category: 'Hoodie',
      size: 'XL',
      stock: 7,
      price: 140000,
      description: 'Hoodie nyaman dengan saku depan',
      imageUrl: 'https://picsum.photos/seed/p9/400/400',
    ),
    Product(
      id: 'p10',
      name: 'Celana Jeans',
      category: 'Celana',
      size: 'L',
      stock: 5,
      price: 130000,
      description: 'Jeans biru tua, potongan straight',
      imageUrl: 'https://picsum.photos/seed/p10/400/400',
    ),
  ];

  List<Product> getAll() => List.unmodifiable(_items);

  Product? getById(String id) {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Product product) {
    _items.add(product);
  }

  void update(Product product) {
    final idx = _items.indexWhere((p) => p.id == product.id);
    if (idx >= 0) _items[idx] = product;
  }

  void delete(String id) {
    _items.removeWhere((p) => p.id == id);
  }

  void updateStock(String id, int delta) {
    final p = getById(id);
    if (p != null) p.stock = (p.stock + delta).clamp(0, 999999);
  }
}
