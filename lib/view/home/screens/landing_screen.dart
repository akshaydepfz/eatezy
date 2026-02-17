import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatezy/services/notification_service.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/home/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showLocalNotification(
          id: notification.hashCode & 0x7FFFFFFF,
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body.toString()),
                    ],
                  ),
                ),
              );
            });
      }
    });
    super.initState();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _customerBlockedStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.empty();
    return FirebaseFirestore.instance
        .collection('customers')
        .doc(uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _customerBlockedStream(),
      builder: (context, snapshot) {
        final isBlocked = snapshot.hasData &&
            snapshot.data!.exists &&
            (snapshot.data!.data()?['is_blocked'] == true);
        if (isBlocked) {
          return Scaffold(body: const _BlockedScreen());
        }
        return Scaffold(
          body: provider.pages[provider.selectedIndex],
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
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
          ),
        );
      },
    );
  }
}

class _BlockedScreen extends StatelessWidget {
  const _BlockedScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.block,
                size: 80,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'You are blocked',
                style: GoogleFonts.rubik(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your account has been blocked due to suspicious activity.',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'For support, contact us at',
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                'support@eatezy.in',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
