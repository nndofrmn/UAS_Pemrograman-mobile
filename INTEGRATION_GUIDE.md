# Integrasi Backend ke Flutter App

Panduan lengkap mengintegrasikan backend Node.js ke aplikasi Flutter.

## 1. Update Flutter Dependencies

Buka `pubspec.yaml` dan tambahkan package untuk HTTP requests:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.0.0  # untuk menyimpan token
```

## 2. Update Services di Flutter

### AuthService - Ganti dengan Backend API

Edit `lib/services/auth_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000/api'; // Ganti dengan IP backend
  AppUser? _currentUser;
  String? _token;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  Future<AppUser?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = AppUser(
          id: data['user']['id'],
          name: data['user']['name'],
          email: data['user']['email'],
          role: data['user']['role'] == 'admin' ? UserRole.admin : UserRole.user,
        );
        // Simpan token ke local storage
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<AppUser?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = AppUser(
          id: data['user']['id'],
          name: data['user']['name'],
          email: data['user']['email'],
          role: UserRole.user,
        );
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  void signOut() {
    _currentUser = null;
    _token = null;
  }
}
```

### ProductService - Ganti dengan Backend API

Edit `lib/services/product_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
```

### Update Product Model

Edit `lib/models/product_model.dart` tambahkan method `fromJson`:

```dart
class Product {
  final String id;
  final String name;
  final String category;
  final String size;
  final int stock;
  final int price;
  final String description;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.stock,
    required this.price,
    required this.description,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      size: json['size'] ?? '',
      stock: json['stock'] ?? 0,
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'size': size,
    'stock': stock,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
  };
}
```

## 3. Perubahan untuk Device/Emulator

Jika menggunakan Android Emulator atau device fisik, ganti URL:

**Windows/Local:**
```dart
final String baseUrl = 'http://localhost:3000/api';
```

**Android Emulator (dari Windows):**
```dart
final String baseUrl = 'http://10.0.2.2:3000/api';
```

**Device Fisik (dari Windows PC):**
```dart
final String baseUrl = 'http://[YOUR_PC_IP]:3000/api';
```

Cari IP PC dengan: `ipconfig` di PowerShell

## 4. Order Service - Ganti dengan Backend API

Buat `lib/services/order_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart'; // Buat model baru

class OrderService {
  final String baseUrl = 'http://localhost:3000/api';
  final String token; // Pass dari AuthProvider

  OrderService(this.token);

  Future<bool> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'items': items}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  Future<List<Order>> getUserOrders() async {
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
}
```

## 5. Testing API dengan Postman

### 1. Register User:
```
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "pass123"
}
```

### 2. Login:
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "pass123"
}
```

Response akan berisi token:
```json
{
  "message": "Login successful",
  "user": {...},
  "token": "eyJhbGc..."
}
```

### 3. Get Products (No Auth):
```
GET http://localhost:3000/api/products
```

### 4. Create Order (with Token):
```
POST http://localhost:3000/api/orders
Content-Type: application/json
Authorization: Bearer [TOKEN_DARI_LOGIN]

{
  "items": [
    {
      "productId": "p1",
      "quantity": 2
    }
  ]
}
```

## 6. Troubleshooting

**CORS Error?** - Backend sudah punya CORS enabled, pastikan Flutter app mengakses URL yang benar.

**Connection Refused?** - Pastikan backend running: `npm start` di folder backend

**401 Unauthorized?** - Token expired atau tidak dikirim. Login ulang.

**Device tidak bisa akses localhost?** - Gunakan IP PC atau setup proxy.

---

Backend sudah 100% ready untuk diintegrasikan! 🎉
