import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RestaurantsListScreen extends StatelessWidget {
  const RestaurantsListScreen({super.key});

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
                CarouselSlider.builder(
                  itemCount: 1,
                  itemBuilder: (context, i, l) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                            image: AssetImage('assets/images/kfc.png'),
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      height: 140, // Match the carousel height
                      width: MediaQuery.of(context).size.width,
                    );
                  },
                  options: CarouselOptions(
                    viewportFraction: 1,
                    aspectRatio: 1.0,
                    autoPlay: true,
                    initialPage: 0,
                    height: 140,
                  ),
                ),
                AppSpacing.h20,
                Text(
                  'All Restaurants',
                  style: GoogleFonts.rubik(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                AppSpacing.h10,
                Consumer<HomeProvider>(builder: (context, p, _) {
                  if (p.vendors == null) {
                    return SizedBox();
                  }
                  return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: p.vendors!.length,
                      itemBuilder: (context, i) {
                        return Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantViewScreen(
                                            vendor: p.vendors![i],
                                          )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              p.vendors![i].shopImage),
                                        )),
                                    AppSpacing.w10,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.vendors![i].shopName,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.place,
                                              size: 15,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              "${p.vendors![i].estimateDistance} away",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        AppSpacing.h5,
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: Colors.red.shade100),
                                          padding: EdgeInsets.all(3),
                                          child: Text(
                                            '30% off, up to ₹300',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
