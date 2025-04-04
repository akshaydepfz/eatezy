import 'package:eatezy/utils/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: GoogleFonts.rubik(
                    fontSize: 17, fontWeight: FontWeight.w600),
              ),
              AppSpacing.h20,
              Expanded(
                  child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.4,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 80,
                            width: 80,
                            child: Image.asset('assets/images/burger.png')),
                        AppSpacing.h10,
                        Text(
                          'Burgers',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  );
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
