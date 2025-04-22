import 'package:eatezy/main.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/home/widgets/bottom_nav_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
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
