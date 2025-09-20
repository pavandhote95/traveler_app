import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ExpertsProfileController extends GetxController {
  var expert = {}.obs;
  var isLoading = true.obs;

  final box = GetStorage();

  Future<void> fetchExpertDetail(int id) async {
    try {
      isLoading.value = true;

      final token = box.read('token');
      if (token == null) {
        Get.snackbar("Error", "No token found. Please login first.");
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse("http://kotiboxglobaltech.com/travel_app/api/experts/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          expert.value = data["data"];
        } else {
          Get.snackbar("Error", data["message"] ?? "Failed to fetch expert");
        }
      } else {
        Get.snackbar("Error", "Failed to fetch expert: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
