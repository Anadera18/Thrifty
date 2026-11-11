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
