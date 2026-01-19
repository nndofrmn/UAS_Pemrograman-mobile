class Product {
  String id;
  String name;
  String category;
  String size;
  int stock;
  int price;
  String description;
  String? imageUrl;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.stock,
    required this.price,
    required this.description,
    this.imageUrl,
    this.imagePath,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'] as String,
    name: map['name'] as String,
    category: map['category'] as String,
    size: map['size'] as String,
    stock: map['stock'] as int,
    price: map['price'] as int,
    description: map['description'] as String,
    imageUrl: map['imageUrl'] as String?,
    imagePath: map['imagePath'] as String?,
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'size': size,
    'stock': stock,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'imagePath': imagePath,
  };
}
