enum ProductType { gold, gem, skin, booster }

class Product {
  final String? name;
  final String price;
  final bool locked;
  final ProductType type;
  final String? icon;   // 아이콘 방식 (선택적)
  final String? image;  // 이미지 방식 (선택적)

  Product({
    required this.name,
    required this.price,
    required this.locked,
    required this.type,
    this.icon,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      price: json['price'],
      locked: json['locked'],
      type: ProductType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      icon: json['icon'],   // 없으면 null
      image: json['image'], // 없으면 null
    );
  }
}