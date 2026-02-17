import 'package:eatezy/services/app_version_service.dart';
import 'package:eatezy/services/notification_service.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/auth/screens/login_screen.dart';
import 'package:eatezy/view/auth/services/auth_screen.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:eatezy/view/cart/services/payment_provider.dart';
import 'package:eatezy/view/chat/chat_service.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/it_park/services/it_service.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:eatezy/view/profile/services/profile_service.dart';
import 'package:eatezy/view/restaurants/provider/restuarant_provider.dart';
import 'package:eatezy/view/restaurants/services/saved_items_service.dart';
import 'package:eatezy/widgets/update_app_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  await initNotificationService();
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
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
        ChangeNotifierProvider(create: (context) => OrderService()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => LoginSrvice()),
        ChangeNotifierProvider(create: (context) => ItService()),
        ChangeNotifierProvider(create: (context) => ProfileService()),
        ChangeNotifierProvider(create: (context) => SavedItemsService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eatezy',
        theme: ThemeData(
          textTheme: GoogleFonts.rubikTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
          useMaterial3: true,
        ),
        home: const AppVersionChecker(),
      ),
    );
  }
}

/// Widget that checks for app updates before showing the main app
class AppVersionChecker extends StatefulWidget {
  const AppVersionChecker({super.key});

  @override
  State<AppVersionChecker> createState() => _AppVersionCheckerState();
}

class _AppVersionCheckerState extends State<AppVersionChecker> {
  final AppVersionService _versionService = AppVersionService();
  bool _isChecking = true;
  bool _updateRequired = false;
  String? _latestVersion;
  String? _updateUrl;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    try {
      final isUpdateRequired = await _versionService.isUpdateRequired();
      final latestVersion = await _versionService.getLatestVersion();
      final updateUrl = await _versionService.getUpdateUrl();

      if (mounted) {
        setState(() {
          _isChecking = false;
          _updateRequired = isUpdateRequired;
          _latestVersion = latestVersion;
          _updateUrl = updateUrl;
        });

        // Show update dialog if update is required
        if (_updateRequired && _latestVersion != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showUpdateDialog(
              context,
              latestVersion: _latestVersion!,
              updateUrl: _updateUrl,
            );
          });
        }
      }
    } catch (e) {
      // If version check fails, continue with app (don't block user)
      if (mounted) {
        setState(() {
          _isChecking = false;
          _updateRequired = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking version
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show main app
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnp) {
        if (userSnp.hasData) {
          return const LandingScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
