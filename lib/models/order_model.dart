class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final int price;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
  };
}

class Order {
  final String id;
  final String userId;
  final int totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      items: (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'totalPrice': totalPrice,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}
