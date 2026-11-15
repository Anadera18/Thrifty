import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductPhotoUpload {
  const ProductPhotoUpload({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
}

class ProductPublishException implements Exception {
  const ProductPublishException(this.message);

  final String message;

  @override
  String toString() => message;
}

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
    required List<ProductPhotoUpload> photos,
  }) async {
    if (photos.isEmpty || photos.length > 6) {
      throw const ProductPublishException('Add between 1 and 6 photos.');
    }
    if (_requireSignedInUser() != sellerId) {
      throw const ProductPublishException('Your session changed. Please sign in again.');
    }

    final productId = _newUuidV4();
    final paths = <String>[];
    final imageUrls = <String>[];

    try {
      for (var index = 0; index < photos.length; index++) {
        final photo = photos[index];
        final path = '$sellerId/$productId/${(index + 1).toString().padLeft(2, '0')}.${photo.extension}';
        paths.add(path);
        await _client.storage.from('product-images').uploadBinary(
              path,
              photo.bytes,
              fileOptions: FileOptions(
                cacheControl: '3600',
                upsert: false,
                contentType: photo.contentType,
              ),
            );
        imageUrls.add(_client.storage.from('product-images').getPublicUrl(path));
      }
    } catch (_) {
      final cleanupSucceeded = await _removeUploadedPhotos(paths);
      throw ProductPublishException(
        cleanupSucceeded
            ? 'Photo upload failed. No listing was published; your form is still here. Check your connection and try again.'
            : 'Photo upload failed. No listing was published, but some uploaded files may need cleanup. Your form is still here.',
      );
    }

    try {
      await _client.from('products').insert({
        'id': productId,
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
        'image_urls': imageUrls,
        'ai_grade': aiGrade,
        'ai_confidence': aiConfidence,
        'final_grade': finalGrade,
        'grade_overridden': aiGrade != finalGrade,
        'status': 'active',
      });
    } catch (_) {
      // A lost response can make the insert outcome unclear. Check for the
      // generated row before deleting its photos, so a committed listing never
      // loses its image files.
      try {
        final existing = await _client
            .from('products')
            .select('id')
            .eq('id', productId)
            .eq('seller_id', sellerId)
            .maybeSingle();
        if (existing != null) return;
      } catch (_) {
        throw const ProductPublishException(
          'Could not confirm whether the listing was published. Refresh My Listings before trying again.',
        );
      }

      final cleanupSucceeded = await _removeUploadedPhotos(paths);
      throw ProductPublishException(
        cleanupSucceeded
            ? 'Listing could not be saved. Uploaded photos were removed; your form is still here.'
            : 'Listing could not be saved and some uploaded photos may need cleanup. Your form is still here.',
      );
    }
  }

  Future<bool> _removeUploadedPhotos(List<String> paths) async {
    if (paths.isEmpty) return true;
    try {
      await _client.storage.from('product-images').remove(paths);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _newUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
