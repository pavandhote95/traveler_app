import 'package:get/get.dart';

import '../controllers/y_controller.dart';

class YBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YController>(
      () => YController(),
    );
  }
}
