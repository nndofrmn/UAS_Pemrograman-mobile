import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'uas_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        size TEXT NOT NULL,
        stock INTEGER NOT NULL,
        price INTEGER NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT,
        imagePath TEXT
      )
    ''');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Cart items table
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        imagePath TEXT,
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        totalPrice INTEGER NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        items TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
  }

  // Product operations
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProduct(String id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Cart operations
  Future<void> addToCart(String id, String productId, String productName, int price, int quantity, String? imagePath) async {
    final db = await database;
    await db.insert(
      'cart_items',
      {
        'id': id,
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
        'imagePath': imagePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('cart_items');
  }

  Future<void> updateCartItem(String id, int quantity) async {
    final db = await database;
    await db.update('cart_items', {'quantity': quantity}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeFromCart(String id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // Order operations
  Future<void> insertOrder(String id, String userId, int totalPrice, String status, String createdAt, String items) async {
    final db = await database;
    await db.insert('orders', {
      'id': id,
      'userId': userId,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'items': items,
    });
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final db = await database;
    return await db.query('orders', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
  }

  // Close database
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
