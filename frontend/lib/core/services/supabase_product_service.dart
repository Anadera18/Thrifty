import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class SupabaseProductService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<ProductModel>> fetchActiveProducts({String? category}) async {
    final rows = category == null || category == 'All'
        ? await _client
              .from('products')
              .select()
              .eq('status', 'active')
              .order('created_at', ascending: false)
        : await _client
              .from('products')
              .select()
              .eq('status', 'active')
              .eq('category', category)
              .order('created_at', ascending: false);

    return rows.map((row) => ProductModel.fromSupabase(row)).toList();
  }

  Future<List<ProductModel>> fetchSellerProducts(String sellerId) async {
    final rows = await _client
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return rows.map((row) => ProductModel.fromSupabase(row)).toList();
  }

  Future<void> updateProductDetails({
    required String productId,
    required String name,
    required String brand,
    required String size,
    required String category,
    required int price,
    required String description,
    required String pickupLocation,
  }) async {
    final sellerId = _requireSignedInUser();
    final rows = await _client
        .from('products')
        .update({
          'name': name,
          'brand': brand,
          'size': size,
          'category': category,
          'price': price,
          'description': description,
          'pickup_location': pickupLocation,
        })
        .eq('id', productId)
        .eq('seller_id', sellerId)
        .select('id');

    if (rows.isEmpty) {
      throw StateError('Listing was not found or is not owned by this account.');
    }
  }

  Future<void> markProductSold(String productId) async {
    final sellerId = _requireSignedInUser();
    final rows = await _client
        .from('products')
        .update({'status': 'sold'})
        .eq('id', productId)
        .eq('seller_id', sellerId)
        .select('id');

    if (rows.isEmpty) {
      throw StateError('Listing was not found or is not owned by this account.');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final sellerId = _requireSignedInUser();
    final rows = await _client
        .from('products')
        .delete()
        .eq('id', productId)
        .eq('seller_id', sellerId)
        .select('id');

    if (rows.isEmpty) {
      throw StateError('Listing was not found or is not owned by this account.');
    }
  }

  String _requireSignedInUser() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in is required to change a listing.');
    }
    return userId;
  }

  Future<void> createProduct({
    required String sellerId,
    required String name,
    required String brand,
    required String size,
    required String category,
    required int price,
    required String description,
    required String pickupLocation,
    required double latitude,
    required double longitude,
    required String aiGrade,
    required double aiConfidence,
    required String finalGrade,
  }) async {
    await _client.from('products').insert({
      'seller_id': sellerId,
      'name': name,
      'brand': brand,
      'size': size,
      'category': category,
      'price': price,
      'description': description,
      'pickup_location': pickupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'image_urls': <String>[],
      'ai_grade': aiGrade,
      'ai_confidence': aiConfidence,
      'final_grade': finalGrade,
      'grade_overridden': aiGrade != finalGrade,
      'status': 'active',
    });
  }
}
