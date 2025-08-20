import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // ✅ Import http
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';
import 'package:travel_app2/app/services/api_service.dart';

class BottomSheetQuestionsController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs;
  final RxString selectedLocation = ''.obs;
  final RxString questionText = ''.obs;
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();
  final RxBool isPickingImage = false.obs;
  final RxBool isLoading = false.obs;
  final CommunityController communityController = Get.find<CommunityController>();
  final TextEditingController locationController = TextEditingController();

  // 🔹 Added for City Search
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;

  // 📦 Cache all cities once
  final List<String> _allCitiesCache = [];
  bool _citiesLoaded = false;


  // Pick multiple images
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

  void clearImages() {
    selectedImages.clear();
  }

  // void updateLocation(String? location) {
  //   selectedLocation.value = location ?? '';
  // }

  void updateQuestion(String value) {
    questionText.value = value;
  }

  void updateLocation(String value) {
    selectedLocation.value = value;
    // keep the field in sync when we set from a suggestion
    if (locationController.text != value) {
      locationController.text = value;
      locationController.selection = TextSelection.fromPosition(
        TextPosition(offset: locationController.text.length),
      );
    }
  }

  // API fetch
  Future<void> _loadCitiesOnce() async {
    if (_citiesLoaded) return;
    try {
      isSearching.value = true;
      final url = Uri.parse(
        "https://api.kosontechnology.com/country-state-city.php?country=IN&city=ALL",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // ✅ API uses "name", not "city_name"
        _allCitiesCache
          ..clear()
          ..addAll(
            data.map((e) => (e['name'] ?? e['city_name'] ?? '').toString())
                .where((s) => s.isNotEmpty),
          );
        _allCitiesCache.sort((a, b) => a.compareTo(b)); // nice alphabetical
        _citiesLoaded = true;
      } else {
        Get.snackbar("Error", "Failed to load cities: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "API error: $e");
    } finally {
      isSearching.value = false;
    }
  }

  // Filter suggestions
  Future<void> fetchCities(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    if (!_citiesLoaded) {
      await _loadCitiesOnce();
    }
    final q = query.toLowerCase();
    final results = _allCitiesCache
        .where((c) => c.toLowerCase().contains(q))
        .take(25) // limit to keep the list snappy
        .toList();
    searchResults.assignAll(results);
  }

  Future<void> submitPost() async {
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

        try {
          await communityController.fetchPosts();
        } catch (e) {
          Get.snackbar('Warning', 'Post created but failed to fetch updated posts: $e',
              backgroundColor: Colors.orange, colorText: Colors.white);
        }

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