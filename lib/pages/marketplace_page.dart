import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product.dart';
import '../data/network_errors.dart';
import '../providers/marketplace_providers.dart';

const _brand = Color(0xFF12373F);
const _mint = Color(0xFF14B8A6);
const _categories = <({String label, String? value})>[
  (label: 'All', value: null),
  (label: 'Shirt', value: 'shirt'),
  (label: 'T-Shirt', value: 't-shirt'),
  (label: 'Pants', value: 'pants'),
  (label: 'Jacket', value: 'jacket'),
];

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  int _selectedTab = 0;
  double? _pendingRadius;
  String _searchQuery = '';
  final Set<String> _savedProductIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final filters = ref.watch(marketplaceFiltersProvider);
    final productsState = ref.watch(nearbyProductsProvider);
    final radius = _pendingRadius ?? filters.radiusKm;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900 ? 3 : 2;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _brand,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: _brand.withValues(alpha: .18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.checkroom_rounded,
                color: _mint,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'THRIFTY',
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: 'Saved items',
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.person_outline,
                color: colors.onPrimaryContainer,
                size: 19,
              ),
            ),
          ),
        ],
      ),
      body: _selectedTab == 0
          ? _buildHome(context, filters, productsState, radius, columns)
          : _ComingSoonPage(
              title: const [
                'Home',
                'Explore',
                'Add Product',
                'Listings',
                'Profile',
              ][_selectedTab],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: colors.surface,
        indicatorColor: colors.secondaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(
    BuildContext context,
    MarketplaceFilters filters,
    AsyncValue<List<Product>> productsState,
    double radius,
    int columns,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ink = colors.onSurface;
    final selectedCategory = filters.category;

    return RefreshIndicator(
      onRefresh: () => ref.read(nearbyProductsProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Home',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.location_on_outlined),
            label: const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Malang, Jawa Timur',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: ink,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              side: BorderSide(color: ink.withValues(alpha: .16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: colors.surfaceContainerLow,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search preloved finds',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Filter settings',
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RadiusCard(
            radius: radius,
            ink: ink,
            background: colors.secondaryContainer,
            onChanged: (value) => setState(() => _pendingRadius = value),
            onChangeEnd: (value) {
              setState(() => _pendingRadius = null);
              ref.read(marketplaceFiltersProvider.notifier).setRadius(value);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category.value == selectedCategory;
                return ChoiceChip(
                  label: Text(category.label),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(marketplaceFiltersProvider.notifier)
                      .selectCategory(category.value),
                  selectedColor: colors.primary,
                  backgroundColor: colors.surfaceContainerLow,
                  labelStyle: TextStyle(
                    color: selected ? colors.onPrimary : ink,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected
                        ? colors.primary
                        : ink.withValues(alpha: .12),
                  ),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Drops',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Secondhand finds around Malang',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ink.withValues(alpha: .65),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                label: const Text('Nearest'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          productsState.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(36),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _MessageCard(
              icon: Icons.cloud_off_outlined,
              message: friendlyErrorMessage(error),
              actionLabel: 'Retry',
              onAction: () => ref.invalidate(nearbyProductsProvider),
            ),
            data: (products) {
              final visibleProducts = products
                  .where(
                    (product) =>
                        _searchQuery.isEmpty ||
                        product.title.toLowerCase().contains(_searchQuery),
                  )
                  .toList(growable: false);

              if (visibleProducts.isEmpty) {
                return _MessageCard(
                  icon: Icons.checkroom_outlined,
                  message: products.isEmpty
                      ? 'No listings in this area yet. New local finds will appear here.'
                      : 'No listings match your search.',
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 278,
                ),
                itemBuilder: (context, index) {
                  final product = visibleProducts[index];
                  return _ProductCard(
                    product: product,
                    ink: ink,
                    saved: _savedProductIds.contains(product.id),
                    onSave: () => setState(() {
                      if (!_savedProductIds.add(product.id)) {
                        _savedProductIds.remove(product.id);
                      }
                    }),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RadiusCard extends StatelessWidget {
  const _RadiusCard({
    required this.radius,
    required this.ink,
    required this.background,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double radius;
  final Color ink;
  final Color background;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar_rounded, color: ink, size: 20),
              const SizedBox(width: 8),
              Text(
                'Search radius',
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${radius.round()} km',
                style: TextStyle(color: ink, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          Slider(
            value: radius,
            min: 1,
            max: 15,
            divisions: 14,
            activeColor: _mint,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 km · Walk', style: TextStyle(fontSize: 11, color: ink)),
              Text(
                '15 km · Transit',
                style: TextStyle(fontSize: 11, color: ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.ink,
    required this.saved,
    required this.onSave,
  });

  final Product product;
  final Color ink;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = switch (product.category) {
      'shirt' || 't-shirt' => const Color(0xFFE7E1D9),
      'pants' => const Color(0xFFE8E2D6),
      'jacket' => const Color(0xFFDCE8E8),
      _ => colors.surfaceContainerHighest,
    };
    final icon = switch (product.category) {
      'shirt' => Icons.dry_cleaning,
      't-shirt' => Icons.checkroom,
      'pants' => Icons.airline_seat_legroom_reduced,
      'jacket' => Icons.layers_outlined,
      _ => Icons.checkroom_outlined,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 142,
                width: double.infinity,
                child: product.imageUrl == null
                    ? ColoredBox(
                        color: tint,
                        child: Icon(
                          icon,
                          size: 58,
                          color: _brand.withValues(alpha: .55),
                        ),
                      )
                    : Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            ColoredBox(
                              color: tint,
                              child: Icon(
                                icon,
                                size: 58,
                                color: _brand.withValues(alpha: .55),
                              ),
                            ),
                      ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _Badge(
                  ink: ink,
                  icon: Icons.auto_awesome,
                  text: product.conditionGrade == null
                      ? 'AI grade pending'
                      : 'Grade ${product.conditionGrade}',
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton.filled(
                  tooltip: saved ? 'Remove from saved items' : 'Save item',
                  onPressed: onSave,
                  icon: Icon(
                    saved ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: .94),
                    foregroundColor: saved ? const Color(0xFFB54758) : _brand,
                    minimumSize: const Size(34, 34),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: _mint,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.title,
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Rp ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 13, color: ink),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Local seller',
                        style: TextStyle(
                          fontSize: 10,
                          color: ink.withValues(alpha: .67),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.ink, required this.icon, required this.text});

  final Color ink;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: ink),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: ink,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerLow,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: colors.primary, size: 30),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, color: colors.primary, size: 38),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'This screen is in the Thrifty prototype plan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
