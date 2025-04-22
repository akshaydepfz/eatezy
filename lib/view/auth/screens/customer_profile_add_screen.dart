import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/auth/services/auth_screen.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:flutter/material.dart';
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
                        backgroundImage: provider.image != null
                            ? FileImage(provider.image!)
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
              PrimaryTextField(title: 'Address', controller: provider.adresss),
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
  });
  final String title;
  final TextEditingController controller;
  FormFieldValidator<String>? validator;

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
          decoration: const InputDecoration(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepOrange)),
            disabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        )
      ],
    );
  }
}
