import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/auth/screens/otp_screen.dart';
import 'package:eatezy/view/auth/services/auth_screen.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginSrvice>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              AppSpacing.h20,
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Premium Restaurant pickups\njust a tap away.',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              Spacer(),
              // LottieBuilder.asset('assets/lottie/login.json'),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Text('+91'),
                    const SizedBox(height: 30, child: VerticalDivider()),
                    Expanded(
                      child: TextField(
                        controller: provider.mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone Number',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h10,
              // Consumer<AuthProvider>(builder: (context, p, _) {
              //   return TextField(
              //     obscureText: p.isVisible,
              //     decoration: InputDecoration(
              //       enabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(12),
              //           borderSide: BorderSide(color: Colors.grey.shade300)),
              //       disabledBorder: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(12),
              //           borderSide: BorderSide(color: Colors.grey.shade300)),
              //       border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(12),
              //           borderSide: BorderSide(color: Colors.grey.shade300)),
              //       suffixIcon: IconButton(
              //         onPressed: () => p.onVisibleChange(),
              //         icon: p.isVisible
              //             ? const Icon(Icons.visibility_off)
              //             : const Icon(Icons.visibility),
              //       ),
              //       hintText: 'Password',
              //     ),
              //   );
              // }),
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: TextButton(
              //       onPressed: () {,
              //       child: const Text(
              //         'Forgot Password?',
              //         style: TextStyle(color: AppColor.primary),
              //       )),
              // ),
              AppSpacing.h20,
              PrimaryButton(
                  isLoading: provider.isLoading,
                  label: 'Continue',
                  onTap: () {
                    provider.verifyPhoneNumber(context);
                  }),
              AppSpacing.h15, Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
