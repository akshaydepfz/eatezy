import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:eatezy/view/restaurants/services/saved_items_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class CategoryViewScreen extends StatefulWidget {
  const CategoryViewScreen(
      {super.key, required this.image, required this.category});
  final String image;
  final String category;
  @override
  State<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends State<CategoryViewScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<RestuarantProvider>(context, listen: false)
        .fetchCategoryProducts(widget.category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedItemsService>(context, listen: false).loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartService>(context);
    final restuarantProvider = Provider.of<RestuarantProvider>(context);
    final savedService = Provider.of<SavedItemsService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: AppColor.primary, borderRadius: BorderRadius.only()),
            child: Row(
              children: [
                Hero(
                  tag: widget.category,
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.image),
                    ),
                  ),
                ),
                AppSpacing.w10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category,
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${restuarantProvider.catProducts?.length ?? 0} items found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Consumer<RestuarantProvider>(
              builder: (context, p, _) {
                if (p.catProducts == null) {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 160,
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
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: p.catProducts!.length,
                  itemBuilder: (context, index) {
                    final product = p.catProducts![index];
                    final cartIndex = provider.selectedProduct
                        .indexWhere((item) => item.id == product.id);
                    final quantity = cartIndex != -1
                        ? provider.selectedProduct[cartIndex].itemCount
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MenuItemCard(
                        product: product,
                        quantity: quantity,
                        isSaved: savedService.isSaved(product.id),
                        restaurantName: product.shopName,
                        onAdd: () => provider.addProductWithVendorCheck(context, product),
                        onRemove: () {
                          final i = provider.selectedProduct
                              .indexWhere((item) => item.id == product.id);
                          if (i != -1) provider.onItemRemove(i);
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
          ),
          ],
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
