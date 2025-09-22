import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ExpertsProfileController extends GetxController {
  var expert = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  final box = GetStorage();

  Future<void> fetchExpertDetail(int id) async {
    isLoading.value = true;

    try {
      final token = box.read('token');
      if (token == null) {
        Get.snackbar("Error", "No token found. Please login first.");
        return;
      }

      final response = await http.get(
        Uri.parse("http://kotiboxglobaltech.com/travel_app/api/experts/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      // Parse response
      final data = jsonDecode(response.body);

      // Only update expert if success and data exists
      if (response.statusCode == 200 && data["success"] == true && data["data"] != null) {
        expert.value = data["data"];
        // Optional: You can show a success snackbar if you want
        // Get.snackbar("Success", "Expert details fetched successfully");
      } else {
        // Show error only if something went wrong
        // Get.snackbar("Error", data["message"] ?? "Failed to fetch expert");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to get languages as a comma-separated string
  String getLanguages() {
    if (expert.value["language"] != null) {
      List langs = expert.value["language"];
      return langs.map((e) => e["value"].toString()).join(", ");
    }
    return "";
  }
}
