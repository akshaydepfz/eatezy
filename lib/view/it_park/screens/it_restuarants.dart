import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItParkRestuarantsScreen extends StatefulWidget {
  const ItParkRestuarantsScreen(
      {super.key,
      required this.name,
      required this.id,
      required this.image,
      required this.distance});
  final String name;
  final String id;
  final String image;
  final String distance;

  @override
  State<ItParkRestuarantsScreen> createState() =>
      _ItParkRestuarantsScreenState();
}

class _ItParkRestuarantsScreenState extends State<ItParkRestuarantsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.image), fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${widget.distance} Away",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.h20,
                Text(
                  'Restaurants',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                AppSpacing.h20,
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
        ],
      ),
    );
  }
}
