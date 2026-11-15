class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.grade,
    required this.description,
    required this.imageUrls,
    required this.distance,
    required this.rating,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatar,
    required this.pickupLocation,
    this.latitude,
    this.longitude,
    required this.size,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String name;
  final String brand;
  final int price;
  final String category;
  final String grade;
  final String description;
  final List<String> imageUrls;
  final String distance;
  final String rating;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final String pickupLocation;
  final double? latitude;
  final double? longitude;
  final String size;
  final String status;
  final DateTime? createdAt;

  String get formattedPrice {
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  factory ProductModel.fromSupabase(Map<String, dynamic> row) {
    final sellerName = row['seller_name']?.toString() ?? 'Seller';
    final imageUrls = row['image_urls'];
    final createdAt = row['created_at']?.toString();

    return ProductModel(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      brand: row['brand']?.toString() ?? '',
      price: (row['price'] as num?)?.toInt() ?? 0,
      category: row['category']?.toString() ?? '',
      grade: 'Grade ${row['final_grade']?.toString() ?? ''}'.trim(),
      description: row['description']?.toString() ?? '',
      imageUrls: imageUrls is List
          ? imageUrls.whereType<String>().toList(growable: false)
          : const <String>[],
      distance: 'Distance unavailable',
      rating: 'No reviews yet',
      sellerId: row['seller_id']?.toString() ?? '',
      sellerName: sellerName,
      sellerAvatar: _initials(sellerName),
      pickupLocation: row['pickup_location']?.toString() ?? '',
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      size: row['size']?.toString() ?? '',
      status: row['status']?.toString() ?? '',
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'S' : initials;
  }

}
