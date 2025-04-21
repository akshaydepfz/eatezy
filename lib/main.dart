import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/auth/screens/login_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => RestuarantProvider()),
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(create: (context) => OrderService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eatezy',
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
