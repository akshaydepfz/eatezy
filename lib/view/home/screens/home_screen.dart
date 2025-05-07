import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_icons.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:eatezy/view/categories/screens/category_view_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/home/widgets/custom_icon.dart';
import 'package:eatezy/view/profile/services/profile_service.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:eatezy/view/top_dish/screens/top_dish_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    Provider.of<HomeProvider>(context, listen: false).getLocationAndAddress();
    Provider.of<HomeProvider>(context, listen: false).gettVendors();
    Provider.of<HomeProvider>(context, listen: false).fetchCategory();
    Provider.of<HomeProvider>(context, listen: false).fetchTopProducts();
    Provider.of<HomeProvider>(context, listen: false).updateAdminFcmToken();
    Provider.of<ProfileService>(context, listen: false).getCustomer();
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
                    Row(
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
                ),
                AppSpacing.h20,
                Text(
                  'Categories',
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
                  if (p.category == null) {
                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.9),
                      itemCount: 8,
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
                                    borderRadius: BorderRadius.circular(12)),
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
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.9),
                    itemCount: p.category!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoryViewScreen(
                                        image: p.category![index].image,
                                        category: p.category![index].name,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Hero(
                                tag: p.category![index].name,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: Image.network(
                                          p.category![index].image)),
                                ),
                              ),
                              AppSpacing.h5,
                              Text(p.category![index].name),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                AppSpacing.h10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Restaurants',
                      style: GoogleFonts.rubik(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.arrow_forward))
                  ],
                ),
                AppSpacing.h10,
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
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: p.vendors!.length,
                        itemBuilder: (context, i) {
                          return RestuarantCard(
                              distance: p.vendors![i].estimateDistance,
                              time: p.vendors![i].estimateTime,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RestaurantViewScreen(
                                              vendor: p.vendors![i],
                                            )));
                              },
                              image: p.vendors![i].shopImage,
                              name: p.vendors![i].shopName);
                        }),
                  );
                }),
                AppSpacing.h10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Dishes',
                      style: GoogleFonts.rubik(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.arrow_forward))
                  ],
                ),
                AppSpacing.h10,
                SizedBox(
                  height: 200,
                  child: Consumer<HomeProvider>(builder: (context, p, _) {
                    if (p.topProducts == null) {
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: 6,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Center(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                  ),
                                ),
                              ),
                            );
                          });
                    }
                    return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: p.topProducts!.length,
                        itemBuilder: (context, i) {
                          return TopDishCard(
                              image: p.topProducts![i].image,
                              name: p.topProducts![i].name,
                              price: p.topProducts![i].price.toString());
                        });
                  }),
                ),
                AppSpacing.h20,
                CarouselSlider.builder(
                  itemCount: 1,
                  itemBuilder: (context, i, l) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                            image: AssetImage('assets/images/banner.png'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      height: 170, // Match the carousel height
                      width: MediaQuery.of(context).size.width,
                    );
                  },
                  options: CarouselOptions(
                    viewportFraction: 1,
                    aspectRatio: 1.0,
                    autoPlay: true,
                    initialPage: 0,
                    height: 170,
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

class TopDishCard extends StatelessWidget {
  const TopDishCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
  });
  final String image;
  final String name;
  final String price;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => TopDishScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                  height: 100, width: 100, child: Image.network(image)),
            ),
            AppSpacing.h5,
            SizedBox(
                width: 100,
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )),
            Text('₹$price'),
            AppSpacing.h5,
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                '#1 MOST LIKED',
                style: TextStyle(fontSize: 10),
              ),
            )
          ],
        ),
      ),
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
    required this.time,
  });
  final String image;
  final String name;
  final Function() onTap;
  final String distance;
  final String time;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                  height: 100,
                  width: 160,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                  )),
            ),
            AppSpacing.h5,
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  '3.4',
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
                AppSpacing.w5,
                Text(
                  '|',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                AppSpacing.w5,
                Text(
                  distance,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.green,
                ),
                AppSpacing.w5,
                Text(
                  time,
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
            Text(
              'FREE delivery on first order',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
