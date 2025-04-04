import 'package:eatezy/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantViewScreen extends StatelessWidget {
  const RestaurantViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                        onPressed: () {},
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
                  Container(
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
                            onPressed: () {}, icon: Icon(Icons.arrow_forward))
                      ],
                    ),
                  ),
                  AppSpacing.h20,
                  Text(
                    'Featured Items',
                    style: GoogleFonts.rubik(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return Column(
                            children: [
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(image: AssetImage('assets/images/'))
                                ),
                              )
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
