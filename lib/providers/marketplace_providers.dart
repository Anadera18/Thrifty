import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(dioProvider)),
);

class MarketplaceFilters {
  const MarketplaceFilters({this.category, this.radiusKm = 5});

  final String? category;
  final double radiusKm;

  MarketplaceFilters copyWith({
    String? category,
    bool clearCategory = false,
    double? radiusKm,
  }) {
    return MarketplaceFilters(
      category: clearCategory ? null : category ?? this.category,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}

class MarketplaceFiltersNotifier extends Notifier<MarketplaceFilters> {
  @override
  MarketplaceFilters build() => const MarketplaceFilters();

  void selectCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
  }

  void setRadius(double radiusKm) {
    state = state.copyWith(radiusKm: radiusKm);
  }
}

final marketplaceFiltersProvider =
    NotifierProvider<MarketplaceFiltersNotifier, MarketplaceFilters>(
      MarketplaceFiltersNotifier.new,
    );

class NearbyProductsNotifier extends AsyncNotifier<List<Product>> {
  // Temporary Malang city-center coordinates until device geolocation is added.
  static const _latitude = -7.9666;
  static const _longitude = 112.6326;

  @override
  Future<List<Product>> build() {
    final filters = ref.watch(marketplaceFiltersProvider);
    final repository = ref.watch(productRepositoryProvider);
    return repository.fetchNearbyProducts(
      latitude: _latitude,
      longitude: _longitude,
      radiusKm: filters.radiusKm,
      category: filters.category,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final nearbyProductsProvider =
    AsyncNotifierProvider<NearbyProductsNotifier, List<Product>>(
      NearbyProductsNotifier.new,
      retry: (retryCount, error) => null,
    );
