import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import 'package:travel_app2/app/services/api_service.dart';

class LoginController extends GetxController {
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final apiService = Get.find<ApiService>();
  final box = GetStorage();

  void login() async {
    final input = emailOrPhoneController.text.trim();
    final password = passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      CustomToast.showErrorHome(Get.context!, 'Please enter all fields');
      return;
    }

    isLoading.value = true;

    try {
      final bool isPhone = RegExp(r'^\d+$').hasMatch(input);

      final response = await apiService.loginUser(
        email: isPhone ? null : input,
        phoneNumber: isPhone ? input : null,
        password: password,
      );

      final data = jsonDecode(response.body);
      isLoading.value = false;

      if (response.statusCode == 200) {
        final token = data['token'];
        final userData = data['data'] ?? {};
        final int userId = userData['id'] ?? 0;
        final int userPoints = userData['user_points'] ?? 0;

        if (token != null) {
          // ✅ Save token, userId, userPoints
          box.write('token', token);
          box.write('userId', userId);
          box.write('userPoints', userPoints);

          debugPrint("📦 Token: $token");
          debugPrint("🆔 UserId: $userId");
          debugPrint("⭐ UserPoints: $userPoints");

          CustomToast.showSuccess(Get.context!, 'Enter OTP');

          // Navigate to OTP or Home screen
          Get.toNamed(Routes.OTP, arguments: {
            'input': input,
            'isPhone': isPhone,
            'token': token,
            'userId': userId,
            'userPoints': userPoints,
          });
        } else {
          CustomToast.showError(Get.context!, 'Token not found');
        }
      } else {
        CustomToast.showError(Get.context!, data['message'] ?? 'Login Failed');
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint("Login Exception: $e");
      CustomToast.showError(Get.context!, 'Something went wrong. Try again.');
    }
  }

  void logout() {
    box.erase();
    debugPrint("🔒 Cleared all storage");
    Get.offAllNamed(Routes.LOGIN);
    CustomToast.showSuccess(Get.context!, 'Logged out successfully');
  }

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
