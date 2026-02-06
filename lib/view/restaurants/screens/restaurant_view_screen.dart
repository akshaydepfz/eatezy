import 'package:eatezy/map_example.dart';
import 'package:eatezy/model/offer_model.dart';
import 'package:eatezy/model/product_model.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:eatezy/view/restaurants/services/saved_items_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantViewScreen extends StatefulWidget {
  const RestaurantViewScreen({super.key, required this.vendor});
  final VendorModel vendor;

  @override
  State<RestaurantViewScreen> createState() => _RestaurantViewScreenState();
}

class _RestaurantViewScreenState extends State<RestaurantViewScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<RestuarantProvider>(context, listen: false)
        .fetchProducts(widget.vendor.id);
    Provider.of<RestuarantProvider>(context, listen: false)
        .fetchOffers(widget.vendor.id);
    Provider.of<RestuarantProvider>(context, listen: false)
        .calculateDistanceAndTime(widget.vendor.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedItemsService>(context, listen: false).loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartService>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    color: widget.vendor.banner != ''
                        ? Colors.transparent
                        : Colors.grey.shade300,
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: widget.vendor.banner != ''
                        ? Image.network(
                            widget.vendor.banner,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.share,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Positioned(
                    left: 20,
                    top: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.vendor.shopImage),
                          ),
                        ),
                        AppSpacing.h10,
                        Text(
                          widget.vendor.shopName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.h10,
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.grey,
                          size: 16,
                        ),
                        AppSpacing.w5,
                        Text(
                          '4.7 (400+ Ratings) | ${widget.vendor.estimateDistance} away',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    AppSpacing.h10,
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OSMTrackingScreen(
                              orderStatus: '',
                              customerImage: '',
                              customerName: '',
                              orderID: '',
                              vendorToken: '',
                              vendorId: '',
                              chatId: '',
                              vendorImage: widget.vendor.shopImage,
                              vendorName: widget.vendor.shopName,
                              vendorPhone: widget.vendor.phone,
                              isOrder: false,
                              lat: double.parse(widget.vendor.lat),
                              long: double.parse(widget.vendor.long),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/map.svg'),
                                AppSpacing.w10,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Direction to Restaurant',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                        '${widget.vendor.estimateDistance} away from you'),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.h20,
                    Consumer<RestuarantProvider>(
                      builder: (context, p, _) {
                        final offersList = p.offers;
                        if (offersList == null || offersList.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_offer_rounded,
                                  size: 20,
                                  color: AppColor.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Offers',
                                  style: GoogleFonts.rubik(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.h10,
                            SizedBox(
                              height: 148,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: offersList.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final offer = offersList[index];
                                  ProductModel? product;
                                  for (final e in [
                                    ...?p.products,
                                    ...(p.featuredProducts ?? [])
                                  ]) {
                                    if (e.id == offer.productId) {
                                      product = e;
                                      break;
                                    }
                                  }
                                  return _OfferCard(
                                    offer: offer,
                                    product: product,
                                    vendorId: widget.vendor.id,
                                  );
                                },
                              ),
                            ),
                            AppSpacing.h20,
                          ],
                        );
                      },
                    ),
                    Consumer<RestuarantProvider>(
                      builder: (context, p, _) {
                        if (p.featuredProducts == null) {
                          return SizedBox();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Featured Items',
                              style: GoogleFonts.rubik(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            AppSpacing.h10,
                            SizedBox(
                              height: 175,
                              child: ListView.builder(
                                itemCount: p.featuredProducts!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  final product = p.featuredProducts![i];
                                  final offer =
                                      p.getOfferForProduct(product.id);
                                  final displayPrice = offer != null
                                      ? offer.getDiscountedPrice(product.price)
                                      : product.price;
                                  final displaySlashed = offer != null
                                      ? product.price.toStringAsFixed(2)
                                      : product.slashedPrice;
                                  final cartIndex = provider.selectedProduct
                                      .indexWhere(
                                          (item) => item.id == product.id);
                                  final isSelected = cartIndex != -1;
                                  return ProductCard(
                                    onRemove: () {
                                      final idx = provider.selectedProduct
                                          .indexWhere(
                                              (item) => item.id == product.id);
                                      if (idx != -1) provider.onItemRemove(idx);
                                    },
                                    isSelected: isSelected,
                                    isActive: product.isActive,
                                    onTap: () {
                                      final toAdd = offer != null
                                          ? product.copyWithPrice(
                                              price: offer.getDiscountedPrice(
                                                  product.price),
                                              slashedPrice: product.price
                                                  .toStringAsFixed(2))
                                          : product;
                                      provider.addProductWithVendorCheck(
                                          context, toAdd);
                                    },
                                    image: product.image,
                                    name: product.name,
                                    price: displayPrice.toStringAsFixed(2),
                                    slashedPrice: displaySlashed,
                                  );
                                },
                              ),
                            ),
                            Divider(color: Colors.grey.shade300),
                            AppSpacing.h20,
                          ],
                        );
                      },
                    ),
                    Text(
                      'All Items',
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.h10,
                    Consumer2<RestuarantProvider, SavedItemsService>(
                      builder: (context, p, savedService, _) {
                        if (p.products == null) {
                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: p.products!.length,
                          itemBuilder: (context, index) {
                            final product = p.products![index];
                            final offer = p.getOfferForProduct(product.id);
                            final cartIndex = provider.selectedProduct
                                .indexWhere((item) => item.id == product.id);
                            final quantity = cartIndex != -1
                                ? provider.selectedProduct[cartIndex].itemCount
                                : 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: MenuItemCard(
                                product: product,
                                offer: offer,
                                quantity: quantity,
                                isSaved: savedService.isSaved(product.id),
                                showRestaurantName: false,
                                onAdd: () {
                                  final toAdd = offer != null
                                      ? product.copyWithPrice(
                                          price: offer.getDiscountedPrice(
                                              product.price),
                                          slashedPrice:
                                              product.price.toStringAsFixed(2))
                                      : product;
                                  provider.addProductWithVendorCheck(
                                      context, toAdd);
                                },
                                onRemove: () {
                                  if (cartIndex != -1) {
                                    provider.onItemRemove(cartIndex);
                                  }
                                },
                                onShare: () {
                                  Share.share(
                                    'Download the Eatezy app and enjoy ${product.name} and ${product.description}',
                                    subject: product.name,
                                  );
                                },
                                onSaveToggle: () =>
                                    savedService.toggleSaved(product.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: provider.selectedProduct.isNotEmpty,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: AppColor.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 40,
                  width: 100,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.selectedProduct.length,
                    itemBuilder: (context, index) {
                      return Transform.translate(
                        offset: Offset(-index * 40, 0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              provider.selectedProduct[index].image,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'View cart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${provider.selectedProduct.length} ITEMS",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                AppSpacing.w20,
                CircleAvatar(
                  backgroundColor: Colors.green.shade500,
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.product,
    required this.vendorId,
  });
  final OfferModel offer;
  final ProductModel? product;
  final String vendorId;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartService>(context);
    final isPercentage = offer.discountType == 'percentage';
    final discountText = isPercentage
        ? '${offer.discountValue.toInt()}% OFF'
        : '₹${offer.discountValue.toInt()} OFF';
    final displayPrice =
        product != null ? offer.getDiscountedPrice(product!.price) : 0.0;
    final originalPrice = product?.price ?? 0.0;
    final cartIndex = product != null
        ? cartProvider.selectedProduct
            .indexWhere((item) => item.id == product!.id)
        : -1;
    final isSelected = cartIndex != -1;
    final quantity =
        isSelected ? cartProvider.selectedProduct[cartIndex].itemCount : 0;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary.withOpacity(0.08),
            AppColor.primary.withOpacity(0.02),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 88,
                          height: 124,
                          child: offer.productImage.isNotEmpty
                              ? Image.network(
                                  offer.productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.local_offer_rounded,
                                    size: 36,
                                    color: AppColor.primary.withOpacity(0.6),
                                  ),
                                ),
                        ),
                      ),
                      if (product != null)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: isSelected
                                ? () {
                                    if (cartIndex != -1) {
                                      cartProvider.onItemRemove(cartIndex);
                                    }
                                  }
                                : () {
                                    final toAdd = product!.copyWithPrice(
                                      price: offer
                                          .getDiscountedPrice(product!.price),
                                      slashedPrice:
                                          product!.price.toStringAsFixed(2),
                                    );
                                    cartProvider.addProductWithVendorCheck(
                                        context, toAdd);
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? Icon(
                                      quantity > 1
                                          ? Icons.remove
                                          : Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    )
                                  : Icon(
                                      Icons.add,
                                      color: AppColor.primary,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            discountText,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          offer.title,
                          style: GoogleFonts.rubik(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (offer.productName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            offer.productName,
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (product != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '₹${displayPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primary,
                                ),
                              ),
                              if (originalPrice > displayPrice) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '₹${originalPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.slashedPrice,
    required this.onTap,
    required this.isSelected,
    required this.onRemove,
    this.isActive = true,
  });
  final String image;
  final String name;
  final String price;
  final String slashedPrice;
  final Function() onTap;
  final Function() onRemove;
  final bool isSelected;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final soldOut = !isActive;
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 10),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return LottieBuilder.asset(
                            'assets/lottie/load.json',
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return LottieBuilder.asset(
                              'assets/lottie/load.json',
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                      if (soldOut)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Sold out',
                            style: GoogleFonts.rubik(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!soldOut)
                isSelected
                    ? Positioned(
                        bottom: 10,
                        right: 20,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    : Positioned(
                        bottom: 10,
                        right: 20,
                        child: GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.add, color: Colors.black),
                          ),
                        ),
                      )
            ],
          ),
          AppSpacing.h5,
          SizedBox(width: 80, child: Text(name)),
          Row(
            children: [
              Text(
                '₹$price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: soldOut ? Colors.grey : null,
                ),
              ),
              AppSpacing.w10,
              Text(
                '₹$slashedPrice',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough),
              ),
              if (soldOut) ...[
                AppSpacing.w5,
                Text(
                  'Sold out',
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.isSaved,
    required this.onAdd,
    required this.onRemove,
    required this.onShare,
    required this.onSaveToggle,
    this.restaurantName,
    this.showRestaurantName = true,
    this.offer,
  });

  final ProductModel product;
  final int quantity;
  final bool isSaved;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onShare;
  final VoidCallback onSaveToggle;

  /// When true (e.g. category view), show restaurant name at top. When false (e.g. restaurant view), show offer tag instead.
  final String? restaurantName;
  final bool showRestaurantName;

  /// When set, display discounted price and slashed original.
  final OfferModel? offer;

  /// Restaurant name from optional param or product's shop_name from Firestore.
  String get _displayRestaurantName {
    final name = (restaurantName ?? product.shopName).trim();
    return name.isEmpty ? 'Restaurant' : name;
  }

  int? _discountPercent() {
    if (offer != null) {
      final original = product.price;
      if (original <= 0) return null;
      final discounted = offer!.getDiscountedPrice(original);
      final pct = ((original - discounted) / original * 100).round();
      return pct > 0 ? pct : null;
    }
    if (product.slashedPrice.isEmpty) return null;
    final original =
        double.tryParse(product.slashedPrice.replaceAll(RegExp(r'[^\d.]'), ''));
    if (original == null || original <= 0) return null;
    final pct = ((original - product.price) / original * 100).round();
    return pct > 0 ? pct : null;
  }

  double get _displayPrice =>
      offer != null ? offer!.getDiscountedPrice(product.price) : product.price;

  String get _displaySlashedPrice =>
      offer != null ? product.price.toStringAsFixed(2) : product.slashedPrice;

  bool get _soldOut => !product.isActive;

  @override
  Widget build(BuildContext context) {
    final discount = _discountPercent();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showRestaurantName && _displayRestaurantName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.store, size: 18, color: AppColor.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _displayRestaurantName,
                          style: GoogleFonts.rubik(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColor.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '₹${_displayPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _soldOut ? Colors.grey : null,
                            ),
                          ),
                          if (_displaySlashedPrice.isNotEmpty &&
                              (offer != null ||
                                  product.slashedPrice.isNotEmpty)) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹$_displaySlashedPrice',
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (discount != null &&
                              discount > 0 &&
                              !_soldOut) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$discount% OFF',
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                          if (_soldOut) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Sold out',
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description.isEmpty
                            ? 'No description'
                            : product.description.length > 60
                                ? '${product.description.substring(0, 60)}...more'
                                : product.description,
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'NOT ELIGIBLE FOR COUPONS',
                        style: GoogleFonts.rubik(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: onSaveToggle,
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 22,
                              color: isSaved
                                  ? AppColor.primary
                                  : Colors.grey.shade600,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                          IconButton(
                            onPressed: onShare,
                            icon: Icon(Icons.share_outlined,
                                size: 22, color: Colors.grey.shade600),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return LottieBuilder.asset(
                                        'assets/lottie/load.json',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return LottieBuilder.asset(
                                        'assets/lottie/load.json',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                  if (_soldOut)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Sold out',
                                        style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (!_soldOut)
                              Positioned(
                                bottom: -10,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            AppColor.primary.withOpacity(0.6),
                                        width: 1.2),
                                  ),
                                  child: quantity > 0
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: onRemove,
                                              child: Icon(
                                                Icons.remove,
                                                size: 20,
                                                color: AppColor.primary,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Text(
                                                '$quantity',
                                                style: GoogleFonts.rubik(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColor.primary,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: onAdd,
                                              child: Icon(
                                                Icons.add,
                                                size: 20,
                                                color: AppColor.primary,
                                              ),
                                            ),
                                          ],
                                        )
                                      : GestureDetector(
                                          onTap: onAdd,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'ADD',
                                                style: GoogleFonts.rubik(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColor.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.add,
                                                  size: 18,
                                                  color: AppColor.primary),
                                            ],
                                          ),
                                        ),
                                ),
                              )
                            else
                              Positioned(
                                bottom: -10,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Sold out',
                                    style: GoogleFonts.rubik(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
