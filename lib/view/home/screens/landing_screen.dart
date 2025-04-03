import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/home/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    return Scaffold(
      body: provider.pages[provider.selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Consumer<HomeProvider>(builder: (context, p, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BottomNavButton(
                icon: 'assets/icons/home.svg',
                isSelected: p.selectedIndex == 0,
                onTap: () => p.onSelectedChange(0),
              ),
              BottomNavButton(
                icon: 'assets/icons/category.svg',
                isSelected: p.selectedIndex == 1,
                onTap: () => p.onSelectedChange(1),
              ),
              BottomNavButton(
                icon: 'assets/icons/restaurant.svg',
                isSelected: p.selectedIndex == 2,
                onTap: () => p.onSelectedChange(2),
              ),
              BottomNavButton(
                icon: 'assets/icons/profile.svg',
                isSelected: p.selectedIndex == 3,
                onTap: () => p.onSelectedChange(3),
              ),
            ],
          );
        }),
      ),
    );
  }
}
