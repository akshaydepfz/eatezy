import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_icons.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/it_park/screens/it_park_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LandingScreen()));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * .28,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColor.primary),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEARBY RESTAURANTS',
                            style: GoogleFonts.poppins(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          AppSpacing.h5,
                          Text(
                            'Order food from restaurants close to you.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          AppSpacing.h10,
                          Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                                height: 80,
                                child: Image.asset(
                                    'assets/images/restaurants.png')),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.w10,
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItParksList()));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * .28,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColor.primary),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IT Park Food Hubs'.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: AppColor.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          AppSpacing.h5,
                          Text(
                            'Pick up food from nearby IT parks.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          AppSpacing.h10,
                          Align(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                                height: 100,
                                child: Image.asset(
                                    'assets/images/skyscraper.png')),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h20,
            Text('FEATURED FOR YOU'),
          ],
        ),
      ),
    );
  }
}
