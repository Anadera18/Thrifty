import 'package:dio/dio.dart';

import '../models/product.dart';

class ProductRepository {
  const ProductRepository(this._dio);

  final Dio _dio;

  Future<List<Product>> fetchNearbyProducts({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? category,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/products/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius_km': radiusKm,
        'category': ?category,
      },
    );
    final data = response.data ?? const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }
}
