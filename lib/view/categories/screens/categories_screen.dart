import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/categories/screens/category_view_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

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
              Consumer<HomeProvider>(builder: (context, p, _) {
                if (p.category == null) {
                  return SizedBox();
                }
                return Expanded(
                    child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: p.category!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryViewScreen(
                                      image: p.category![index].image,
                                      category: p.category![index].name,
                                    )));
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: p.category![index].name,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                    height: 80,
                                    width: 100,
                                    child: Image.network(
                                      p.category![index].image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return LottieBuilder.asset(
                                          'assets/lottie/load.json',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return LottieBuilder.asset(
                                            'assets/lottie/load.json',
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      },
                                    )),
                              ),
                            ),
                            AppSpacing.h10,
                            Text(
                              p.category![index].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ));
              })
            ],
          ),
        ),
      ),
    );
  }
}
