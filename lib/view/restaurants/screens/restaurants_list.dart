import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: 10,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => RestaurantViewScreen(
                          //               vendor: Vemd,
                          //             )));
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
                                      backgroundImage: AssetImage(
                                          'assets/images/kfc_logo.png'),
                                    )),
                                AppSpacing.w10,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KFC',
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
                                          '12 Km away',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 13),
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
                                            fontSize: 11, color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.grey.shade300,
                                ))
                          ],
                        ),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
