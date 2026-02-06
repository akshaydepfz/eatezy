import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/orders/screens/order_screen.dart';
import 'package:eatezy/view/profile/screens/edit_profile_screen.dart';
import 'package:eatezy/view/profile/screens/favorites_screen.dart';
import 'package:eatezy/view/profile/services/profile_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileService>(context);
    return Scaffold(
      body: provider.customer == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Center(
                        child: SizedBox(
                            height: 70,
                            width: 70,
                            child: CircleAvatar(
                                backgroundImage: provider.customer!.image == ''
                                    ? null
                                    : NetworkImage(provider.customer!.image)))),
                    AppSpacing.h10,
                    Text(
                      provider.customer!.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.h10,
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'General',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          AppSpacing.h20,
                          ProfileTile(
                            icon: 'assets/icons/people.png',
                            label: provider.customer!.name,
                          ),
                          AppSpacing.h10,
                          Divider(color: Colors.grey.shade300),
                          AppSpacing.h10,
                          ProfileTile(
                            icon: 'assets/icons/iphone.png',
                            label: provider.customer!.phoneNumber,
                          ),
                          AppSpacing.h10,
                          Divider(color: Colors.grey.shade300),
                          AppSpacing.h10,
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: Icon(
                                    Icons.edit,
                                    size: 25,
                                    color: AppColor.primary,
                                  ),
                                ),
                                AppSpacing.w10,
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          AppSpacing.h10,
                          Divider(color: Colors.grey.shade300),
                          AppSpacing.h10,
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderScreeen()));
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: SvgPicture.asset(
                                      'assets/icons/order.svg',
                                      color: AppColor.primary,
                                    )),
                                AppSpacing.w10,
                                Text(
                                  'My Orders',
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          AppSpacing.h10,
                          Divider(color: Colors.grey.shade300),
                          AppSpacing.h10,
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FavoritesScreen()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bookmark_border,
                                  size: 25,
                                  color: AppColor.primary,
                                ),
                                AppSpacing.w10,
                                const Text(
                                  'Favorites',
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h20,
                    AppSpacing.h20,
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          AppSpacing.h20,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Image.asset(
                                        'assets/icons/chat.png',
                                        color: AppColor.primary,
                                      )),
                                  AppSpacing.w10,
                                  const Text(
                                    'Push noifications',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                  activeColor: AppColor.primary,
                                  value: provider.isPushNotifed,
                                  onChanged: (v) => provider.changeNotified(v))
                            ],
                          )
                        ],
                      ),
                    ),
                    AppSpacing.h20,
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            onTap: () async {
                              provider.showLogoutConfirmationDialog(context);
                              // await FirebaseAuth.instance.signOut();
                              // Navigator.pushAndRemoveUntil(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => const LoginScreen()),
                              //   (Route<dynamic> route) =>
                              //       false, // This condition removes all previous routes.
                              // );
                            },
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            title: const Text('Logout'),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.label,
  });
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            height: 25,
            width: 25,
            child: Image.asset(
              icon,
              color: AppColor.primary,
            )),
        AppSpacing.w10,
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        )
      ],
    );
  }
}
