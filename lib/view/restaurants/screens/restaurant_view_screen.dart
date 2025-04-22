import 'package:eatezy/map_example.dart';
import 'package:eatezy/model/vendor_model.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
    Provider.of<RestuarantProvider>(context, listen: false)
        .fetchProducts(widget.vendor.id);
    Provider.of<RestuarantProvider>(context, listen: false)
        .calculateDistanceAndTime(widget.vendor.id);
    super.initState();
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
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      'assets/images/kfc.png',
                    ),
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
                    Text(
                      widget.vendor.shopName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.h5,
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
                              orderID: '',
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
                                  return ProductCard(
                                    onTap: () {},
                                    image: p.featuredProducts![i].image,
                                    name: p.featuredProducts![i].name,
                                    price:
                                        p.featuredProducts![i].price.toString(),
                                    slashedPrice:
                                        p.featuredProducts![i].slashedPrice,
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
                    Consumer<RestuarantProvider>(
                      builder: (context, p, _) {
                        if (p.products == null) {
                          return GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Center(
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height: 100,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: p.products!.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              onTap: () {
                                provider.addProduct(p.products![index]);
                              },
                              image: p.products![index].image,
                              name: p.products![index].name,
                              price: p.products![index].price.toString(),
                              slashedPrice: p.products![index].slashedPrice,
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

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.slashedPrice,
    required this.onTap,
  });
  final String image;
  final String name;
  final String price;
  final String slashedPrice;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
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
                    image: DecorationImage(
                        image: NetworkImage(image), fit: BoxFit.cover)),
              ),
              Positioned(
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              AppSpacing.w10,
              Text(
                '₹$slashedPrice',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough),
              )
            ],
          )
        ],
      ),
    );
  }
}
