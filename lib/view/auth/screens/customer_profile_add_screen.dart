import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/auth/services/auth_screen.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

class CustomerDetailsAddScreen extends StatelessWidget {
  const CustomerDetailsAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginSrvice>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Center(
                  child: Stack(
                children: [
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: CircleAvatar(
                        backgroundImage: provider.imageBytes != null
                            ? MemoryImage(provider.imageBytes!)
                            : null,
                        backgroundColor: Colors.grey.shade200,
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        provider.pickImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  )
                ],
              )),
              PrimaryTextField(
                  title: 'Name', controller: provider.nameController),
              AppSpacing.h10,
              if (kIsWeb)
                PrimaryTextField(
                    title: 'Phone Number',
                    controller: provider.mobileController,
                    keyboardType: TextInputType.phone)
              else
                PrimaryTextField(
                    title: 'Email Address',
                    controller: provider.emailController),
              const Spacer(),
              PrimaryButton(
                  label: 'Continue',
                  onTap: () => provider.registerUser(context),
                  isLoading: provider.isLoading),
              AppSpacing.h10,
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryTextField extends StatelessWidget {
  PrimaryTextField({
    super.key,
    required this.title,
    required this.controller,
    this.validator,
    this.keyboardType,
  });
  final String title;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        AppSpacing.h10,
        TextFormField(
          validator: validator,
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primary)),
            disabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        )
      ],
    );
  }
}
