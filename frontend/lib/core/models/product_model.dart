import 'package:cloud_firestore/cloud_firestore.dart';

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
    this.distance = '1.0 km',
    this.rating = '4.9',
    this.sellerId = 'default_seller',
    this.sellerName = 'Dinda Putri',
    this.sellerAvatar = 'DP',
    this.pickupLocation = 'Politeknik Negeri Malang',
    this.latitude,
    this.longitude,
    this.size = 'L',
    this.status = 'active',
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

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ProductModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toInt() : 0,
      category: data['category'] ?? 'T-Shirt',
      grade: data['grade'] ?? 'Grade A',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      distance: data['distance'] ?? '1.2 km',
      rating: data['rating']?.toString() ?? '4.8',
      sellerId: data['sellerId'] ?? 'seller',
      sellerName: data['sellerName'] ?? 'Community Seller',
      sellerAvatar: data['sellerAvatar'] ?? 'CS',
      pickupLocation: data['pickupLocation'] ?? 'Malang, Jawa Timur',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      size: data['size'] ?? 'M',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'category': category,
      'grade': grade,
      'description': description,
      'imageUrls': imageUrls,
      'distance': distance,
      'rating': rating,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'pickupLocation': pickupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'size': size,
      'status': status,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
