import 'dart:io';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:eatezy/view/auth/screens/customer_profile_add_screen.dart';
import 'package:eatezy/view/profile/services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final customer = Provider.of<ProfileService>(context, listen: false).customer;
    _nameController = TextEditingController(text: customer?.name ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileService>(context);
    final customer = provider.customer;
    if (customer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayImage = _pickedImage != null
        ? FileImage(_pickedImage!)
        : (customer.image.isNotEmpty
            ? NetworkImage(customer.image) as ImageProvider
            : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: displayImage,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primary,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h20,
              PrimaryTextField(
                title: 'Name',
                controller: _nameController,
              ),
              AppSpacing.h10,
              PrimaryTextField(
                title: 'Email Address',
                controller: _emailController,
              ),
              AppSpacing.h10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mobile Number'),
                  AppSpacing.h10,
                  TextFormField(
                    initialValue: customer.phoneNumber,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      hintText: 'Cannot be changed',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h20,
              AppSpacing.h10,
              PrimaryButton(
                label: 'Save Changes',
                onTap: provider.isUpdating
                    ? () {}
                    : () => provider.updateProfile(
                          context,
                          name: _nameController.text,
                          email: _emailController.text,
                          newProfileImage: _pickedImage,
                        ),
                isLoading: provider.isUpdating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
