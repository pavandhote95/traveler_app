import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ExpertController extends GetxController {
  var experts = [].obs;
  var isLoading = true.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchExperts();
  }

  Future<void> fetchExperts() async {
    try {
      isLoading.value = true;

      // 📦 Get token from storage
      final token = box.read('token');
      if (token == null) {
        Get.snackbar("Error", "No token found. Please login first.");
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse("http://kotiboxglobaltech.com/travel_app/api/experts"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          experts.value = data["data"];
        }
      } else {
        Get.snackbar("Error", "Failed to fetch experts: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
