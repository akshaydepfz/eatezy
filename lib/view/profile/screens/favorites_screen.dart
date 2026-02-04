import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:eatezy/view/restaurants/services/saved_items_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;
  String? _error;

  Future<void> _loadFavorites() async {
    final savedService = context.read<SavedItemsService>();
    await savedService.loadIfNeeded();
    final ids = savedService.savedIds.toList();
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final restaurantProvider = context.read<RestuarantProvider>();
    final products = await restaurantProvider.fetchProductsByIds(ids);
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<SavedItemsService>(
        builder: (context, savedService, _) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loadFavorites,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (savedService.savedIds.isEmpty)
                      Text(
                        'No favorites yet',
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      )
                    else
                      Text(
                        'Some saved items may no longer be available',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Save items from restaurant menus using the bookmark icon',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _FavoriteItemCard(
                  product: product,
                  isSaved: savedService.isSaved(product.id),
                  onRemove: () async {
                    await savedService.toggleSaved(product.id);
                    await _loadFavorites();
                  },
                  onTap: () => _openRestaurant(context, product),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRestaurant(BuildContext context, ProductModel product) async {
    final vendor = await _getVendorForProduct(context, product.vendorID);
    if (!context.mounted || vendor == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantViewScreen(vendor: vendor),
      ),
    );
  }

  Future<VendorModel?> _getVendorForProduct(
      BuildContext context, String vendorId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return VendorModel.fromFirestore(
          snapshot.data()!, snapshot.id);
    } catch (_) {
      return null;
    }
  }
}

class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard({
    required this.product,
    required this.isSaved,
    required this.onRemove,
    required this.onTap,
  });

  final ProductModel product;
  final bool isSaved;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant, size: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.bookmark,
                  color: AppColor.primary,
                  size: 26,
                ),
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
