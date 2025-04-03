import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_icons.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/home/widgets/custom_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Provider.of<HomeProvider>(context, listen: false).getLocationAndAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const CartScreen()));
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
