import 'dart:async';

import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_icons.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/it_park/screens/it_park_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'view/search/screens/search_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  @override
  void initState() {
    Provider.of<HomeProvider>(context, listen: false).getLocationAndAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
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
                  ],
                ),
                AppSpacing.h10,
                TextField(
                  readOnly: true,
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));
                  },
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
                Text(
                  'Takeaway Made Easy with\nEatezy',
                  style: GoogleFonts.poppins(
                    letterSpacing: -2,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w700,
                    fontSize: 50,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          ContinuousScrollText(
            texts: [
              'Order now from your favorite restaurant!',
              'Skip the queue – pick up in minutes.',
              'Fresh food. Zero wait. Eatezy style!',
            ],
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            backgroundColor: AppColor.primary, // Background color
          ),
        ],
      ),
    );
  }
}

class ContinuousScrollText extends StatefulWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final double textSpacing;
  final Duration scrollDuration;

  const ContinuousScrollText({
    super.key,
    required this.texts,
    this.textStyle,
    this.backgroundColor = Colors.teal,
    this.scrollDuration = const Duration(seconds: 2), // Faster scroll
    this.textSpacing = 20.0,
  });

  @override
  State<ContinuousScrollText> createState() => _ContinuousScrollTextState();
}

class _ContinuousScrollTextState extends State<ContinuousScrollText> {
  final ScrollController _scrollController = ScrollController();
  late double _scrollWidth;

  @override
  void initState() {
    super.initState();
    _scrollWidth = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollWidth = _getScrollWidth();
      _startAutoScroll();
    });
  }

  double _getScrollWidth() {
    double width = 0;
    for (var text in widget.texts) {
      final textWidth = _calculateTextWidth(text);
      width += textWidth + widget.textSpacing; // Add spacing between text
    }
    return width;
  }

  double _calculateTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text, style: widget.textStyle ?? const TextStyle(fontSize: 20)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_scrollController.hasClients) {
        final currentPosition = _scrollController.offset;

        if (currentPosition >= _scrollWidth) {
          _scrollController.jumpTo(0); // Reset to start position
        } else {
          _scrollController.animateTo(
            currentPosition + 2, // Increase the increment to make it faster
            duration: const Duration(milliseconds: 10),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor, // Background color ribbon
      height: 60, // Height for the ribbon
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable manual scrolling
        child: Row(
          children: widget.texts
              .map((text) => Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: widget.textSpacing),
                    child: Text(
                      text,
                      style: widget.textStyle ??
                          const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
