import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/auth/services/auth_screen.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
              if (kIsWeb) ...[
                PrimaryButton(
                  isLoading: provider.isLoading,
                  label: 'Sign in with Google',
                  onTap: () => provider.signInWithGoogle(context),
                ),
              ] else ...[
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
                AppSpacing.h20,
                PrimaryButton(
                    isLoading: provider.isLoading,
                    label: 'Continue',
                    onTap: () {
                      provider.verifyPhoneNumber(context);
                    }),
              ],
              AppSpacing.h15,
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
