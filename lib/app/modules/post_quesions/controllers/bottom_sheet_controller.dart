import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/services/api_service.dart';

class BottomSheetQuestionsController extends GetxController {
  final RxList<File> selectedImages = <File>[].obs;
  final RxString selectedLocation = ''.obs;
  final RxString questionText = ''.obs;
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();
  final RxBool isPickingImage = false.obs;
  final RxBool isLoading = false.obs;

  final TextEditingController locationController = TextEditingController();
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;

  // cache for all locations
  final List<String> _allLocations = [];
  bool _locationsLoaded = false;

  // pick multiple images
  Future<void> pickImages() async {
    if (isPickingImage.value) return;
    try {
      isPickingImage.value = true;
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        selectedImages.addAll(pickedFiles.map((f) => File(f.path)));
      }
    } finally {
      isPickingImage.value = false;
    }
  }

  void updateQuestion(String value) => questionText.value = value;

  void updateLocation(String value) {
    selectedLocation.value = value;
    if (locationController.text != value) {
      locationController.text = value;
      locationController.selection = TextSelection.fromPosition(
          TextPosition(offset: locationController.text.length));
    }
    print("Selected location: $value");
  }

  // load all locations once from API
  Future<void> _loadLocations() async {
    if (_locationsLoaded) return;
    try {
      isSearching.value = true;
      final url = Uri.parse(
          "https://api.kosontechnology.com/country-state-city.php?country=ALL&state=ALL&district=ALL&city=ALL&town=ALL");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Full API Response: $data"); // debug
        _allLocations.clear();
        for (var item in data) {
          final names = [
            item['country_name'],
            item['state_name'],
            item['district_name'],
            item['city_name'],
            item['town_name'],
          ];
          for (var n in names) {
            if (n != null && n.toString().trim().isNotEmpty) {
              _allLocations.add(n.toString().trim());
            }
          }
        }
        _allLocations.sort((a, b) => a.compareTo(b));
        _locationsLoaded = true;
        print("Total locations loaded: ${_allLocations.length}");
      } else {
        Get.snackbar("Error", "Failed to load locations: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "API error: $e");
    } finally {
      isSearching.value = false;
    }
  }

  // fetch locations by keyword
  Future<void> fetchLocations(String query) async {
    print("Search query: '$query'");
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    if (!_locationsLoaded) await _loadLocations();

    final q = query.toLowerCase();
    final results = _allLocations
        .where((c) => c.toLowerCase().contains(q))
        .take(30)
        .toList();
    searchResults.assignAll(results);
    print("Results count: ${results.length}");
    print("Results: $results");
  }

  // submit post
  Future<void> submitPost() async {
    if (questionText.value.isEmpty || selectedLocation.value.isEmpty) {
      Get.snackbar('Error', 'Please enter question and location');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.addPost(
          question: questionText.value,
          location: selectedLocation.value,
          imageFiles: selectedImages.isNotEmpty ? selectedImages : null);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.back();
        Get.snackbar('Success', 'Post created successfully');
        questionText.value = '';
        selectedLocation.value = '';
        selectedImages.clear();
      } else {
        Get.snackbar('Error', 'Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
