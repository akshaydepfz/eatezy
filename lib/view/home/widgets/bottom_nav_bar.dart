import 'package:eatezy/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavButton extends StatelessWidget {
  const BottomNavButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String icon;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          isSelected
              ? Container(
                  width: 50,
                  height: 3,
                  decoration:
                      const BoxDecoration(color: AppColor.primary, boxShadow: [
                    BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 1,
                        color: Colors.greenAccent,
                        offset: Offset(0, 5))
                  ]),
                )
              : const SizedBox(
                  width: 50,
                  height: 3,
                ),
          Container(
              margin: const EdgeInsets.only(top: 20),
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                icon,
                color: isSelected ? AppColor.primary : Colors.grey.shade300,
              )),
        ],
      ),
    );
  }
}
