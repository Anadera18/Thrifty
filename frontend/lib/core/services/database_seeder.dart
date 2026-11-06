import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class DatabaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<ProductModel> initialDummyProducts = [
    const ProductModel(
      id: 'dummy_1',
      name: 'Washed Denim Vintage Trucker Jacket',
      brand: 'Vintage Levi’s',
      price: 145000,
      category: 'Jacket',
      grade: 'Grade A • Like New',
      description:
          'Original 90s vintage washed denim jacket. Heavyweight cotton, zero tears, all buttons intact. Perfect boxy fit for casual layering.',
      imageUrls: [
        'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '800 m',
      rating: '4.9',
      sellerName: 'Dinda Putri',
      sellerAvatar: 'DP',
      pickupLocation: 'Kec. Lowokwaru, Malang',
      latitude: -7.9465,
      longitude: 112.6156,
      size: 'L (Oversized)',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_2',
      name: 'Heavyweight Boxy Crewneck Tee',
      brand: 'Uniqlo U Archive',
      price: 89000,
      category: 'T-Shirt',
      grade: 'Grade A • Like New',
      description:
          'Minimalist thick cotton silhouette designed by Christophe Lemaire in Paris. Clean collar line, no fading, worn twice.',
      imageUrls: [
        'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '1.2 km',
      rating: '4.8',
      sellerName: 'Ahmad Faiz',
      sellerAvatar: 'AF',
      pickupLocation: 'Suhat Street, Malang',
      latitude: -7.9421,
      longitude: 112.6210,
      size: 'M',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_3',
      name: '874 Original Work Pants Khaki',
      brand: 'Dickies',
      price: 120000,
      category: 'Pants',
      grade: 'Grade B • Very Good',
      description:
          'Classic twill straight-leg skate trousers. Minor fading around knees adding authentic vintage patina. Heavy duty zipper and brass hook.',
      imageUrls: [
        'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '2.4 km',
      rating: '4.7',
      sellerName: 'Bagus Pratama',
      sellerAvatar: 'BP',
      pickupLocation: 'Klojen, Malang',
      latitude: -7.9780,
      longitude: 112.6310,
      size: '32',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_4',
      name: 'Corduroy Collar Detroit Work Jacket',
      brand: 'Carhartt WIP',
      price: 210000,
      category: 'Jacket',
      grade: 'Grade A • Mint',
      description:
          'Rugged canvas outer with blanket lining and dark brown corduroy collar. Iconic streetwear piece with gold tone zip chest pocket.',
      imageUrls: [
        'https://images.unsplash.com/photo-1544441893-675973e31985?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '3.1 km',
      rating: '5.0',
      sellerName: 'Dinda Putri',
      sellerAvatar: 'DP',
      pickupLocation: 'Kec. Lowokwaru, Malang',
      latitude: -7.9465,
      longitude: 112.6156,
      size: 'XL',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_5',
      name: 'Classic Plaid Flannel Button-down Shirt',
      brand: 'Polo Ralph Lauren',
      price: 175000,
      category: 'Shirt',
      grade: 'Grade A • Like New',
      description:
          '100% brushed cotton flannel shirt in vintage burgundy and forest green pattern. Embroidered pony logo on left chest. All spare buttons present.',
      imageUrls: [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '3.8 km',
      rating: '4.9',
      sellerName: 'Rian Setyo',
      sellerAvatar: 'RS',
      pickupLocation: 'Blimbing, Malang',
      latitude: -7.9350,
      longitude: 112.6450,
      size: 'L',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_6',
      name: 'Faded World Tour Graphic Streetwear Tee',
      brand: 'Stüssy Archive',
      price: 95000,
      category: 'T-Shirt',
      grade: 'Grade B • Very Good',
      description:
          'Rare graphic print tee from the Stüssy world cities capsule. Naturally washed charcoal shade, clean screenprint without cracking.',
      imageUrls: [
        'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '4.1 km',
      rating: '4.6',
      sellerName: 'Citra Kirana',
      sellerAvatar: 'CK',
      pickupLocation: 'Dinoyo, Malang',
      latitude: -7.9510,
      longitude: 112.6070,
      size: 'M',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_7',
      name: 'Relaxed Fit Oxford Cloth Button Down',
      brand: 'Muji Labo',
      price: 110000,
      category: 'Shirt',
      grade: 'Grade A • Like New',
      description:
          'Organic cotton breathable oxford shirt in sky blue. Washed once, crisp collar and premium stitching throughout.',
      imageUrls: [
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '2.0 km',
      rating: '4.8',
      sellerName: 'Dinda Putri',
      sellerAvatar: 'DP',
      pickupLocation: 'Kec. Lowokwaru, Malang',
      latitude: -7.9465,
      longitude: 112.6156,
      size: 'M',
      status: 'active',
    ),
    const ProductModel(
      id: 'dummy_8',
      name: 'Pleated Corduroy Trousers Earth Brown',
      brand: 'Zara Man Archive',
      price: 135000,
      category: 'Pants',
      grade: 'Grade C • Fair Wear',
      description:
          'Retro high-waisted ribbed corduroy pants with front pleats. Minor cuff fraying at hems suitable for cuffing or tailoring.',
      imageUrls: [
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&auto=format&fit=crop&q=80',
      ],
      distance: '5.2 km',
      rating: '4.5',
      sellerName: 'Kevin Wijaya',
      sellerAvatar: 'KW',
      pickupLocation: 'Sukun, Malang',
      latitude: -7.9950,
      longitude: 112.6180,
      size: '30',
      status: 'active',
    ),
  ];

  /// Checks if products collection is empty and seeds initial items if needed.
  static Future<void> seedIfEmpty() async {
    try {
      final snapshot = await _firestore.collection('products').limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('Firestore products collection is empty. Seeding initial dummy products...');
        await seedAll(force: true);
        debugPrint('Successfully seeded dummy products into Firestore!');
      } else {
        debugPrint('Firestore already contains ${snapshot.docs.length} products. Skipping seeding.');
      }
    } catch (e) {
      debugPrint('Error checking/seeding Firestore: $e');
    }
  }

  /// Seeds all dummy products into Firestore.
  static Future<void> seedAll({bool force = false}) async {
    try {
      final batch = _firestore.batch();
      for (final product in initialDummyProducts) {
        final docRef = _firestore.collection('products').doc(product.id);
        batch.set(docRef, product.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint('DatabaseSeeder: Seeding completed successfully.');
    } catch (e) {
      debugPrint('DatabaseSeeder error: $e');
      rethrow;
    }
  }
}
