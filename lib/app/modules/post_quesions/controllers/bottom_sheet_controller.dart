import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';
import 'package:travel_app2/app/services/api_service.dart';

class BottomSheetQuestionsController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs; // List for multiple images
  final RxString selectedLocation = ''.obs; // Simplified to non-nullable RxString
  final RxString questionText = ''.obs;
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();
  final RxBool isPickingImage = false.obs;
  final RxBool isLoading = false.obs;
  final CommunityController communityController = Get.find<CommunityController>();

  // Pick multiple images from gallery
  Future<void> pickImages() async {
    if (isPickingImage.value) {
      Get.snackbar('Warning', 'Image picker is already active, please wait',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isPickingImage.value = true;
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        Get.snackbar('Success', 'Images selected: ${pickedFiles.length}',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Info', 'No images selected',
            backgroundColor: Colors.blue, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isPickingImage.value = false;
    }
  }

  // Clear selected images
  void clearImages() {
    selectedImages.clear();
  }

  // Update location
  void updateLocation(String? location) {
    selectedLocation.value = location ?? '';
  }

  // Update question text
  void updateQuestion(String value) {
    questionText.value = value;
  }

  // Submit post
  Future<void> submitPost() async {
    // Validate inputs
    if (questionText.value.isEmpty || selectedLocation.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in both question and location fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.addPost(
        question: questionText.value,
        location: selectedLocation.value,
        imageFiles: selectedImages.isNotEmpty ? selectedImages : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.back();
        Get.snackbar('Success', 'Post created successfully',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Fetch updated posts
        try {
          await communityController.fetchPosts();
        } catch (e) {
          Get.snackbar('Warning', 'Post created but failed to fetch updated posts: $e',
              backgroundColor: Colors.orange, colorText: Colors.white);
        }

        // Clear fields
        questionText.value = '';
        selectedLocation.value = '';
        selectedImages.clear();
      } else {
        Get.snackbar('Error', 'Failed to create post: ${response.statusCode} - ${response.reasonPhrase}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}