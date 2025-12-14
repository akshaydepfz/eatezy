import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/auth/screens/login_screen.dart';
import 'package:eatezy/view/auth/services/auth_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/chat/chat_service.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/it_park/services/it_service.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:eatezy/view/profile/services/profile_service.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:eatezy/walkthrough_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', 'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//     playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  if (kIsWeb) {
    // Web Firebase configuration
    // To get your web app ID:
    // 1. Go to https://console.firebase.google.com/
    // 2. Select your project (eatezy-63f35)
    // 3. Click the gear icon ⚙️ > Project settings
    // 4. Scroll down to "Your apps" section
    // 5. If you don't have a web app, click "Add app" and select Web (</>)
    // 6. Copy the "App ID" (format: 1:366816004932:web:xxxxx)
    // 7. Replace "YOUR_WEB_APP_ID" below with your actual web app ID
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB86Zain7mlt10eKZV2a6XFO5OsDPKtvUc",
        appId: "1:366816004932:web:58a1df2eb1e96ca63de511",
        messagingSenderId: "366816004932",
        projectId: "eatezy-63f35",
        storageBucket: "eatezy-63f35.firebasestorage.app",
        authDomain: "eatezy-63f35.firebaseapp.com",
      ),
    );
  } else {
    // Mobile platforms (Android/iOS) - uses google-services.json / GoogleService-Info.plist
    await Firebase.initializeApp();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ignore: unused_local_variable
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
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
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => LoginSrvice()),
        ChangeNotifierProvider(create: (context) => ItService()),
        ChangeNotifierProvider(create: (context) => ProfileService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eatezy',
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
          useMaterial3: true,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, userSnp) {
            if (userSnp.hasData) {
              return const LandingScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
