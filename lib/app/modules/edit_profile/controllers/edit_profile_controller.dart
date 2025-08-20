import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final travelMode = 'Normal'.obs;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  // 🔹 New Controllers
  final locationController = TextEditingController();
  final travelInterestController = TextEditingController();
  final visitedPlacesController = TextEditingController();
  final dreamDestinationController = TextEditingController();
  final languageController = TextEditingController();

  // 🔹 Travel Type (Radio Button)
  var travelType = "Solo".obs;

  final selectedImage = Rx<File?>(null);

  // void updateProfile() {
  //   // handle update logic
  //   print("Travel Type: ${travelType.value}");
  // }

  // final Rx<File?> selectedImage = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  void pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void updateProfile() {
    final name = nameController.text.trim();
    final bio = bioController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    debugPrint("Updating Profile:");
    debugPrint("Name: $name");
    debugPrint("Bio: $bio");
    debugPrint("Email: $email");
    debugPrint("Phone: $phone");
    debugPrint("Image path: ${selectedImage.value?.path}");

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}