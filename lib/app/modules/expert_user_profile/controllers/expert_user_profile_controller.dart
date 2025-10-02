import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class ExpertUserProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = {}.obs;

  final box = GetStorage();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchExpertUserProfile();
    // Poll every 5 seconds to get latest ratings

  }

  @override
  void onClose() {
    _timer?.cancel(); // cancel timer when controller is disposed
    super.onClose();
  }

  Future<void> fetchExpertUserProfile() async {
    try {
      isLoading.value = true;
      final token = box.read('token') ?? "";
      print("📌 Token used: $token");

      final response = await http.get(
        Uri.parse(
            "https://kotiboxglobaltech.com/travel_app/api/expert-user-details"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📩 API Status Code: ${response.statusCode}");
      print("📩 API Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Decoded Response: $data");

        if (data["status"] == true && data["data"] != null) {
          profileData.value = data["data"];
          print("🎯 Profile Data Updated: ${profileData.value}");
        } else {
          print("❌ API Error: ${data["message"]}");
          Get.snackbar("Error", data["message"] ?? "Something went wrong");
        }
      } else {
        print("❌ Failed with status: ${response.statusCode}");
        // Get.snackbar("Error", "Failed to load profile");
      }
    } catch (e) {
      print("🔥 Exception: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
