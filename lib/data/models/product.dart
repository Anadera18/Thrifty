class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.status,
    this.description,
    this.conditionGrade,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final double price;
  final String status;
  final String? description;
  final String? conditionGrade;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final price = switch (rawPrice) {
      num value => value.toDouble(),
      String value => double.tryParse(value) ?? 0,
      _ => 0.0,
    };

    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Untitled listing',
      category: json['category'] as String? ?? 'clothing',
      price: price,
      status: json['status'] as String? ?? 'available',
      description: json['description'] as String?,
      conditionGrade: json['condition_grade'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
