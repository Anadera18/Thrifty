import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductService {
  FirestoreProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  /// Create a new product listing.
  Future<String> createProduct({
    required String sellerId,
    required String sellerName,
    required String name,
    required String brand,
    required int price,
    required String category,
    required String grade,
    required String description,
    required List<String> imageUrls,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    final docRef = await _productsRef.add({
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': name,
      'brand': brand,
      'price': price,
      'category': category,
      'grade': grade,
      'description': description,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName ?? 'Local pickup',
      'status': 'active', // active, sold, draft
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Real-time stream of all active products for the catalog.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveProducts({
    String? category,
  }) {
    Query<Map<String, dynamic>> query = _productsRef.where('status', isEqualTo: 'active');

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  /// Real-time stream of listings posted by a specific seller.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSellerProducts(String sellerId) {
    return _productsRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update an existing product listing.
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _productsRef.doc(productId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a product listing.
  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }
}
