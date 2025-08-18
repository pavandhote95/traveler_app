import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:travel_app2/app/constants/my_toast.dart';
import 'package:travel_app2/app/services/api_service.dart';
import '../../../routes/app_pages.dart';

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
        if (token != null) {
          box.write('token', token); // ✅ Store token locally
          debugPrint("📦 Token saved: $token");

          CustomToast.showSuccess(Get.context!, 'Enter OTP ');

          // 👉 Navigate to OTP or Home screen based on flow
  Get.toNamed(Routes.OTP, arguments: {
  'input': input,
  'isPhone': isPhone,
  'token': token, // ✅ Pass the real token to OTP screen
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
    box.remove('token'); // ❌ Clear token
    debugPrint("🔒 Token removed");
    Get.offAllNamed(Routes.LOGIN); // 🔄 Navigate to login screen
    CustomToast.showSuccess(Get.context!, 'Logged out successfully');
  }

  void loginWithGoogle() {
    Get.snackbar("Google Login", "Coming soon!");
  }

  void loginWithApple() {
    Get.snackbar("Apple Login", "Coming soon!");
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
