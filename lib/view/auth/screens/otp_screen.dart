import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:eatezy/view/home/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpAuthScreen extends StatefulWidget {
  static String route = 'otpScreen';
  const OtpAuthScreen({super.key});

  @override
  State<OtpAuthScreen> createState() => _OtpAuthScreenState();
}

class _OtpAuthScreenState extends State<OtpAuthScreen> {
  String otp = '';
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'Please type the verifiation code sent',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'to',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'your mobile number',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * .05,
                  ),
                  PinCodeTextField(
                    enableActiveFill: true,
                    cursorColor: Colors.green,
                    appContext: context,
                    length: 6,
                    pinTheme: PinTheme(
                        selectedFillColor: Colors.grey.shade200,
                        inactiveFillColor: Colors.grey.shade200,
                        activeColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        shape: PinCodeFieldShape.box,
                        inactiveColor: Colors.transparent,
                        selectedColor: Colors.transparent,
                        fieldHeight: height * .06,
                        fieldWidth: height * .06,
                        activeFillColor: Colors.green,
                        disabledColor: Colors.green),
                    onChanged: (v) {
                      setState(() {
                        otp = v;
                      });
                    },
                    onCompleted: (v) {},
                  ),
                  SizedBox(
                    height: height * .05,
                  ),
                  PrimaryButton(
                      label: 'Continue',
                      onTap: () async {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LandingScreen()),
                          (Route<dynamic> route) =>
                              false, // This condition removes all previous routes.
                        );
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Dont receive the OTP?'),
                      TextButton(
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.black),
                        onPressed: () {},
                        child: const Text('Resend'),
                      )
                    ],
                  )
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
