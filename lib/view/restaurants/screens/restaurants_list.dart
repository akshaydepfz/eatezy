import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

const double _kCardRadius = 16;
const Color _kSurface = Color(0xFFF8F9FA);

class RestaurantsListScreen extends StatefulWidget {
  const RestaurantsListScreen({super.key});

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<VendorModel> _filterVendors(List<VendorModel> vendors, String query) {
    if (query.trim().isEmpty) return vendors;
    final lower = query.trim().toLowerCase();
    return vendors.where((v) {
      return v.shopName.toLowerCase().contains(lower) ||
          v.shopAddress.toLowerCase().contains(lower);
    }).toList();
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
          'Restaurants',
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
              child: _SearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (_) => setState(() {}),
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
                  final filtered =
                      _filterVendors(vendors, _searchController.text);
                  if (filtered.isEmpty) {
                    return const _NoSearchResultsState();
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        sliver: SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _searchController.text.trim().isEmpty
                                  ? 'All Restaurants'
                                  : '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                              style: GoogleFonts.rubik(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
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
                                child: _RestaurantCard(
                                  vendor: vendor,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RestaurantViewScreen(
                                                vendor: vendor),
                                      ),
                                    );
                                  },
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search restaurants or address…',
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22,
          color: Colors.grey.shade600,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, size: 20, color: Colors.grey.shade600),
                onPressed: () {
                  controller.clear();
                  onChanged('');
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.rubik(
        fontSize: 14,
        color: Colors.grey.shade900,
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: SizedBox(
          height: 140,
          width: double.infinity,
          child: CarouselSlider.builder(
            itemCount: 1,
            itemBuilder: (context, i, l) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/kfc.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Order from your favourite restaurants',
                    style: GoogleFonts.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              viewportFraction: 1,
              aspectRatio: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              height: 140,
              enableInfiniteScroll: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.vendor,
    required this.onTap,
  });

  final VendorModel vendor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_kCardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(_kCardRadius),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    vendor.shopImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.shopName,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vendor.estimateDistance.isNotEmpty
                                  ? '${vendor.estimateDistance} away'
                                  : vendor.shopAddress.isNotEmpty
                                      ? vendor.shopAddress
                                      : '—',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (vendor.estimateTime.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '~${vendor.estimateTime}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 38),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 24,
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
              'No restaurants found',
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
