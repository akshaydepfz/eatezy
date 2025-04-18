import 'package:eatezy/map_example.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantViewScreen extends StatelessWidget {
  const RestaurantViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          )),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.white,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.share,
                                color: Colors.white,
                              )),
                        ],
                      )
                    ],
                  ),
                  Positioned(
                      left: 20,
                      top: 80,
                      child: Column(
                        children: [
                          SizedBox(
                              height: 80,
                              width: 80,
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/kfc_logo.png'),
                              )),
                          AppSpacing.h10,
                          Text(
                            'KFC',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      )),
                ],
              ),
              AppSpacing.h10,
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KFC',
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
                          '4.7 (400+ Ratings) | 4.7 Km away',
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    AppSpacing.h10,
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OSMTrackingScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12)),
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
                                    Text('4.7 Km away from you')
                                  ],
                                )
                              ],
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.arrow_forward))
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.h20,
                    Text(
                      'Featured Items',
                      style: GoogleFonts.rubik(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    AppSpacing.h10,
                    SizedBox(
                      height: 175,
                      child: ListView.builder(
                          itemCount: 4,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CartScreen()));
                              },
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/kfc_food.png'),
                                                fit: BoxFit.cover)),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 20,
                                        child: Container(
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: Icon(Icons.add,
                                              color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                  AppSpacing.h5,
                                  SizedBox(
                                      width: 80,
                                      child: Text('KFC Bucket Combo')),
                                  Text(
                                    '₹120',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    AppSpacing.h20,
                    Text(
                      'All Items',
                      style: GoogleFonts.rubik(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    AppSpacing.h10,
                    GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CartScreen()));
                          },
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
                                            image: AssetImage(
                                                'assets/images/kfc_food.png'),
                                            fit: BoxFit.cover)),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 20,
                                    child: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child:
                                          Icon(Icons.add, color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                              AppSpacing.h5,
                              SizedBox(
                                  width: 80, child: Text('KFC Bucket Combo')),
                              Text(
                                '₹120',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        );
                      },
                    )
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
