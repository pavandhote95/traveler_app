import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/dm/views/dm_view.dart';
import 'package:travel_app2/app/modules/dm/views/user_model.dart';

class DmController extends GetxController {
  final box = GetStorage();

  RxList<UserModel> users = <UserModel>[].obs;
  RxList<UserModel> travellers = <UserModel>[].obs; // ✅ New list
  RxBool isLoading = true.obs;
  RxBool isTravellersLoading = true.obs; // ✅ New loading

  @override
  void onInit() {
    fetchUsers();
    fetchTravellers(); // ✅ also fetch travellers
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final token = box.read('token');
      if (token == null) {
        Get.snackbar('Error', 'Auth token not found');
        return;
      }

      final url = 'https://kotiboxglobaltech.com/travel_app/api/chat/users';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['status'] == true) {
          final List data = jsonBody['data'];
          users.value = data.map((e) => UserModel.fromJson(e)).toList();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch chat users');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch Travellers
/// ✅ Fetch Travellers (Users available for experts to chat with)
Future<void> fetchTravellers() async {
  try {
    isTravellersLoading.value = true;

    final token = box.read('token');
    if (token == null) {
      Get.snackbar('Error', 'Auth token not found');
      return;
    }

    const url = 'https://kotiboxglobaltech.com/travel_app/api/chat/expert-users';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      if (jsonBody['status'] == true && jsonBody['data'] != null) {
        final List data = jsonBody['data'];
        travellers.value = data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        travellers.clear();
        Get.snackbar('Info', jsonBody['message'] ?? 'No travellers found');
      }
    } else {
      Get.snackbar('Error', 'Failed to fetch travellers (Code: ${response.statusCode})');
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to fetch travellers: $e');
  } finally {
    isTravellersLoading.value = false;
  }
}

}