import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_icons.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:eatezy/view/categories/screens/category_view_screen.dart';
import 'package:eatezy/view/home/screens/select_location_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/home/widgets/custom_icon.dart';
import 'package:eatezy/view/home/widgets/processing_order_bottom_card.dart';
import 'package:eatezy/view/orders/screens/order_screen.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:eatezy/view/profile/services/profile_service.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:eatezy/view/restaurants/services/saved_items_service.dart';
import 'package:eatezy/view/search/screens/search_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Provider.of<HomeProvider>(context, listen: false).loadSavedLocation();
    Provider.of<HomeProvider>(context, listen: false).startVendorsStream();
    Provider.of<HomeProvider>(context, listen: false).fetchCategory();
    Provider.of<HomeProvider>(context, listen: false).fetchTopProducts();
    Provider.of<HomeProvider>(context, listen: false).fetchBanners();
    Provider.of<HomeProvider>(context, listen: false).updateAdminFcmToken();
    Provider.of<ProfileService>(context, listen: false).getCustomer();
    Provider.of<OrderService>(context, listen: false).getOrders();
    Provider.of<OrderService>(context, listen: false).gettVendors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectLocationScreen(),
                          ),
                        ).then((_) {
                          // Refresh location when returning from selection screen
                          Provider.of<HomeProvider>(context, listen: false)
                              .loadSavedLocation();
                          Provider.of<HomeProvider>(context, listen: false)
                              .startVendorsStream();
                        });
                      },
                      child: Row(
                        children: [
                          SizedBox(
                              height: 25,
                              child: Image.asset(
                                AppIcons.location,
                                color: AppColor.primary,
                              )),
                          AppSpacing.w10,
                          Consumer<HomeProvider>(builder: (context, p, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    p.address,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                )
                              ],
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartScreen()));
                        },
                        child: const CustomIcon(icon: AppIcons.bag)),
                  ],
                ),
                AppSpacing.h20,
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search Eatezy",
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(), // Default border
                    ),
                    contentPadding: EdgeInsets.only(top: 5),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));
                  },
                ),
                AppSpacing.h20,
                const _SelfPickupInstructionCard(),
                AppSpacing.h20,
                Text(
                  'what do you want to pick up today ?',
                  style: GoogleFonts.rubik(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                AppSpacing.h10,
                Divider(
                  thickness: 2,
                  color: Colors.grey.shade100,
                ),
                AppSpacing.h10,
                Consumer<HomeProvider>(builder: (context, p, _) {
                  const int crossAxisCount = 2;
                  const double spacing = 10;
                  const double catItemWidth = 90;
                  const double catItemHeight = 100;

                  if (p.category == null) {
                    final double maxWidth =
                        MediaQuery.of(context).size.width - 30;
                    return SizedBox(
                      width: maxWidth,
                      height: crossAxisCount * catItemHeight +
                          (crossAxisCount - 1) * spacing,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            4,
                            (_) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: spacing),
                                  child: Column(
                                    children: List.generate(
                                        crossAxisCount,
                                        (row) => Padding(
                                              padding: EdgeInsets.only(
                                                  bottom:
                                                      row < crossAxisCount - 1
                                                          ? spacing
                                                          : 0),
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  width: catItemWidth,
                                                  height: catItemHeight,
                                                ),
                                              ),
                                            )),
                                  ),
                                )),
                      ),
                    );
                  }
                  if (p.category!.isEmpty) return const SizedBox.shrink();

                  Widget buildCategoryItem(int index) {
                    final c = p.category![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryViewScreen(
                                      image: c.image,
                                      category: c.name,
                                    )));
                      },
                      child: SizedBox(
                        width: catItemWidth,
                        height: catItemHeight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Hero(
                              tag: c.name,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: Image.network(
                                      c.image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return LottieBuilder.asset(
                                          'assets/lottie/load.json',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return LottieBuilder.asset(
                                          'assets/lottie/load.json',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )),
                              ),
                            ),
                            AppSpacing.h5,
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final int columnCount =
                      (p.category!.length + crossAxisCount - 1) ~/
                          crossAxisCount;
                  final double maxWidth =
                      MediaQuery.of(context).size.width - 30;
                  return SizedBox(
                    width: maxWidth,
                    height: crossAxisCount * catItemHeight +
                        (crossAxisCount - 1) * spacing,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: columnCount,
                      itemBuilder: (context, colIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(right: spacing),
                          child: Column(
                            children: List.generate(crossAxisCount, (row) {
                              final index = colIndex * crossAxisCount + row;
                              if (index >= p.category!.length) {
                                return SizedBox(
                                    width: catItemWidth, height: catItemHeight);
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        row < crossAxisCount - 1 ? spacing : 0),
                                child: buildCategoryItem(index),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  );
                }),
                AppSpacing.h10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ready for pick up near you',
                      style: GoogleFonts.rubik(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    // IconButton(
                    //     onPressed: () {
                    //       provider.onSelectedChange(2);
                    //     },
                    //     icon: Icon(Icons.arrow_forward))
                  ],
                ),
                AppSpacing.h20,
                Consumer<HomeProvider>(builder: (context, p, _) {
                  if (p.vendors == null) {
                    return Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12)),
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                          ),
                        ),
                      ),
                    );
                  }
                  final sortedVendors = List.of(p.vendors!)
                    ..sort((a, b) => p
                        .distanceInKmForSorting(a)
                        .compareTo(p.distanceInKmForSorting(b)));
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: sortedVendors.length,
                        itemBuilder: (context, i) {
                          final vendor = sortedVendors[i];
                          final distance = p.computeDistanceToVendor(vendor);
                          final estimatedTime =
                              p.computeEstimatedTimeToVendor(vendor);
                          return RestuarantCard(
                              distance: distance.isNotEmpty
                                  ? '$distance away'
                                  : vendor.estimateDistance,
                              estimatedTime: estimatedTime,
                              isActive: vendor.isActive,
                              openingTime: vendor.openingTime,
                              closingTime: vendor.closingTime,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RestaurantViewScreen(
                                              vendor: vendor,
                                            )));
                              },
                              image: vendor.shopImage,
                              name: vendor.shopName);
                        }),
                  );
                }),
                AppSpacing.h10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending pickups today',
                      style: GoogleFonts.rubik(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                AppSpacing.h15,
                Consumer<HomeProvider>(builder: (context, p, _) {
                  if (p.topProducts == null) {
                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 6,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        });
                  }
                  if (p.topProducts!.isEmpty) return const SizedBox.shrink();
                  final cartProvider = Provider.of<CartService>(context);
                  final savedService = Provider.of<SavedItemsService>(context);
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: p.topProducts!.length,
                      itemBuilder: (context, i) {
                        final product = p.topProducts![i];
                        final cartIndex = cartProvider.selectedProduct
                            .indexWhere((item) => item.id == product.id);
                        final quantity = cartIndex != -1
                            ? cartProvider.selectedProduct[cartIndex].itemCount
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: MenuItemCard(
                            product: product,
                            offer: null,
                            quantity: quantity,
                            isSaved: savedService.isSaved(product.id),
                            showRestaurantName: true,
                            onAdd: () {
                              cartProvider.addProductWithVendorCheck(
                                  context, product);
                            },
                            onRemove: () {
                              if (cartIndex != -1) {
                                cartProvider.onItemRemove(cartIndex);
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
                      });
                }),
                AppSpacing.h20,
                Consumer<HomeProvider>(builder: (context, p, _) {
                  if (p.banners.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12)),
                            width: MediaQuery.of(context).size.width,
                            height: 120,
                          ),
                        ),
                      ),
                    );
                  }
                  return CarouselSlider.builder(
                    itemCount: p.banners.length,
                    itemBuilder: (context, i, l) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              image: NetworkImage(p.banners[i].image),
                              fit: BoxFit.cover),
                        ),
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                      );
                    },
                    options: CarouselOptions(
                        viewportFraction: 1,
                        aspectRatio: 1.0,
                        autoPlay: true,
                        initialPage: 0,
                        height: 150),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Consumer2<CartService, OrderService>(
        builder: (context, cartService, orderService, _) {
          final hasProcessingOrders = orderService.upmcomingedOrders.isNotEmpty;
          final hasCartItems = cartService.selectedProduct.isNotEmpty;

          if (!hasProcessingOrders && !hasCartItems) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasProcessingOrders) ...[
                Consumer<HomeProvider>(builder: (context, homeProvider, _) {
                  final order = orderService.upmcomingedOrders.first;
                  final vendor = orderService.findVendorById(order.vendorId);
                  final distanceText = vendor != null
                      ? homeProvider.computeDistanceToVendor(vendor)
                      : '';
                  return ProcessingOrderBottomCard(
                    order: order,
                    distanceText: distanceText.isNotEmpty
                        ? '$distanceText away'
                        : 'Distance unavailable',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderScreeen(),
                        ),
                      );
                    },
                    onCall: () {
                      final phone = order.vendorPhone.trim();
                      final uri = phone.startsWith('+')
                          ? Uri.parse('tel:$phone')
                          : Uri.parse('tel:+91$phone');
                      launchUrl(uri);
                    },
                  );
                }),
              ],
              if (hasCartItems)
                GestureDetector(
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
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
                            itemCount: cartService.selectedProduct.length,
                            itemBuilder: (context, index) {
                              return Transform.translate(
                                offset: Offset(-index * 40, 0),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: cartService.selectedProduct[index]
                                            .image.isNotEmpty
                                        ? Image.network(
                                            cartService
                                                .selectedProduct[index].image,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(
                                              Icons.restaurant,
                                              size: 32,
                                              color: Colors.grey.shade400,
                                            ),
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
                              "${cartService.selectedProduct.length} ITEMS",
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
            ],
          );
        },
      ),
    );
  }
}

class _SelfPickupInstructionCard extends StatelessWidget {
  const _SelfPickupInstructionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColor.selfPickupBgStart, AppColor.selfPickupBgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Introducing Self Pickup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Order for pickup. Skip the queue!',
            style: TextStyle(
              color: AppColor.selfPickupSubtitle,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InstructionStep(
                  icon: Icons.receipt_long,
                  title: 'Place your order',
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColor.selfPickupArrow,
              ),
              SizedBox(width: 6),
              Expanded(
                child: _InstructionStep(
                  icon: Icons.storefront_rounded,
                  title: 'Reach on ready',
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColor.selfPickupArrow,
              ),
              SizedBox(width: 6),
              Expanded(
                child: _InstructionStep(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Grab your order',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: AppColor.selfPickupStepFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.selfPickupStepBorder),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class RestuarantCard extends StatelessWidget {
  const RestuarantCard({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
    required this.distance,
    required this.estimatedTime,
    required this.isActive,
    required this.openingTime,
    required this.closingTime,
  });
  final String image;
  final String name;
  final Function() onTap;
  final String distance;
  final String estimatedTime;
  final bool isActive;
  final String openingTime;
  final String closingTime;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1 : 0.65,
      child: GestureDetector(
        onTap: isActive ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 160,
                      child: Image.network(
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
                    ),
                    if (!isActive)
                      Container(
                        height: 100,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Closed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.h5,
              SizedBox(
                width: 160,
                child: Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Text(
                    '4.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(
                    Icons.star,
                    size: 15,
                    color: Colors.grey,
                  ),
                  AppSpacing.w5,
                  Text(
                    '(200+)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              if (distance.isNotEmpty || estimatedTime.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      AppSpacing.w5,
                      Text(
                        [
                          if (distance.isNotEmpty) distance,
                          if (estimatedTime.isNotEmpty) estimatedTime,
                        ].join(' · '),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Icon(
                    isActive ? Icons.schedule : Icons.schedule_outlined,
                    size: 12,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                  AppSpacing.w5,
                  Text(
                    isActive
                        ? '$openingTime – $closingTime'
                        : 'Closed · $openingTime – $closingTime',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (!isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Closed',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
