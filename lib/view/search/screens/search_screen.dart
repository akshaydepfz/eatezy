import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:eatezy/view/restaurants/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const Color _kSurface = Color(0xFFF8F9FA);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<ProductModel>? _allProducts;
  bool _isLoadingProducts = false;
  Object? _productsError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  Future<void> _loadProducts() async {
    if (_isLoadingProducts) return;
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(500)
          .get();
      final list = snapshot.docs
          .map((d) => ProductModel.fromFirestore(d.data(), d.id))
          .toList();
      if (!mounted) return;
      setState(() => _allProducts = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _productsError = e);
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  List<VendorModel> _filterVendors(
    List<VendorModel> vendors,
    String query, {
    required Set<String> vendorIdsFromProducts,
  }) {
    if (query.trim().isEmpty) return vendors;
    final lower = query.trim().toLowerCase();
    return vendors.where((v) {
      return v.shopName.toLowerCase().contains(lower) ||
          v.shopAddress.toLowerCase().contains(lower) ||
          vendorIdsFromProducts.contains(v.id);
    }).toList();
  }

  List<ProductModel> _filterProducts(
    List<ProductModel> products,
    String query, {
    required Set<String> allowedVendorIds,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final list = products.where((p) {
      if (p.vendorID.isEmpty || !allowedVendorIds.contains(p.vendorID)) {
        return false;
      }
      if (!p.isActive) return false;
      final hay = '${p.name} ${p.description}'.toLowerCase();
      return hay.contains(q);
    }).toList();

    int score(ProductModel p) {
      final name = p.name.toLowerCase();
      if (name.startsWith(q)) return 0;
      if (name.contains(q)) return 1;
      return 2;
    }

    list.sort((a, b) {
      final s = score(a).compareTo(score(b));
      if (s != 0) return s;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list.take(20).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _kSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.grey.shade800),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Search',
          style: GoogleFonts.rubik(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search dishes, restaurants or address…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              size: 20, color: Colors.grey.shade600),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, _) {
                  if (homeProvider.vendors == null) {
                    return const _LoadingState();
                  }
                  final vendors = homeProvider.vendors!;
                  if (vendors.isEmpty) {
                    return const _EmptyState();
                  }
                  final allowedVendorIds =
                      vendors.where((v) => !v.isSuspend).map((v) => v.id).toSet();
                  final matchingProducts = _filterProducts(
                    _allProducts ?? const [],
                    _searchController.text,
                    allowedVendorIds: allowedVendorIds,
                  );
                  final vendorIdsFromProducts =
                      matchingProducts.map((p) => p.vendorID).toSet();
                  final filtered = _filterVendors(
                    vendors,
                    _searchController.text,
                    vendorIdsFromProducts: vendorIdsFromProducts,
                  );
                  if (_searchController.text.trim().isNotEmpty &&
                      _isLoadingProducts &&
                      filtered.isEmpty &&
                      matchingProducts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColor.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Searching…',
                              style: GoogleFonts.rubik(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (filtered.isEmpty && matchingProducts.isEmpty) {
                    return const _NoSearchResultsState();
                  }
                  final vendorById = <String, VendorModel>{
                    for (final v in vendors) v.id: v,
                  };
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        sliver: SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_searchController.text.trim().isNotEmpty)
                                  Text(
                                    'Products',
                                    style: GoogleFonts.rubik(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                if (_searchController.text.trim().isNotEmpty)
                                  const SizedBox(height: 10),
                                if (_searchController.text.trim().isNotEmpty)
                                  SizedBox(
                                    height: 128,
                                    child: _isLoadingProducts
                                        ? ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 4,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(width: 12),
                                            itemBuilder: (context, index) {
                                              return Container(
                                                width: 240,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : matchingProducts.isEmpty
                                            ? Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  _productsError != null
                                                      ? 'Products unavailable right now'
                                                      : 'No products found',
                                                  style: GoogleFonts.rubik(
                                                    fontSize: 13,
                                                    color:
                                                        Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            : ListView.separated(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    matchingProducts.length,
                                                separatorBuilder: (_, __) =>
                                                    const SizedBox(width: 12),
                                                itemBuilder: (context, i) {
                                                  final p =
                                                      matchingProducts[i];
                                                  final vendor =
                                                      vendorById[p.vendorID];
                                                  final shopName =
                                                      (vendor?.shopName ??
                                                              p.shopName)
                                                          .trim();
                                                  final isRestaurantActive =
                                                      vendor?.isActive ?? true;
                                                  final subtitle =
                                                      p.description.trim();
                                                  return _ProductSearchCard(
                                                    name: p.name,
                                                    description: subtitle,
                                                    imageUrl: p.image,
                                                    restaurantName: shopName
                                                            .isEmpty
                                                        ? 'Restaurant'
                                                        : shopName,
                                                    isRestaurantOpen:
                                                        isRestaurantActive,
                                                    onTap: vendor != null
                                                        ? () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    RestaurantViewScreen(
                                                                        vendor:
                                                                            vendor),
                                                              ),
                                                            );
                                                          }
                                                        : null,
                                                  );
                                                },
                                              ),
                                  ),
                                if (_searchController.text.trim().isNotEmpty)
                                  const SizedBox(height: 18),
                                Text(
                                  _searchController.text.trim().isEmpty
                                      ? 'All Restaurants'
                                      : '${filtered.length} restaurant${filtered.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.rubik(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final vendor = filtered[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: RestaurantCard(
                                  vendor: vendor,
                                  onTap: vendor.isActive
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RestaurantViewScreen(
                                                      vendor: vendor),
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  const _ProductSearchCard({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.restaurantName,
    required this.isRestaurantOpen,
    this.onTap,
  });

  final String name;
  final String description;
  final String imageUrl;
  final String restaurantName;
  final bool isRestaurantOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final desc = description.isEmpty
        ? 'No description'
        : (description.length > 60 ? '${description.substring(0, 60)}…' : description);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 104,
                  child: imageUrl.trim().isEmpty
                      ? Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(Icons.restaurant,
                              color: Colors.grey.shade500),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Icon(Icons.restaurant,
                                color: Colors.grey.shade500),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded,
                            size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            restaurantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRestaurantOpen ? 'Open' : 'Closed',
                      style: GoogleFonts.rubik(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color:
                            isRestaurantOpen ? Colors.green : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading restaurants…',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 56,
                color: AppColor.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No restaurants yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Restaurants near you will show up here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultsState extends StatelessWidget {
  const _NoSearchResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
