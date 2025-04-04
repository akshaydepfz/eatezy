import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/cart/screens/cart_screen.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
          useMaterial3: true,
        ),
        home: const LandingScreen(),
      ),
    );
  }
}
