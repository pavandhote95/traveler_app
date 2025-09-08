import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/dm/views/user_model.dart';

class DmController extends GetxController {
  final box = GetStorage();

  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      // ✅ Get dynamic userId from GetStorage
      final userId = box.read('userId');
      if (userId == null) {
        Get.snackbar('Error', 'User ID not found');
        return;
      }

      final url = 'https://kotiboxglobaltech.com/travel_app/api/get-profile-byid/$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        users.value = [UserModel.fromJson(data)]; // Wrap single user in list
      } else {
        Get.snackbar('Error', 'Failed to fetch user');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
