import 'package:get/get.dart';

import '../controllers/experts_controller.dart';

class ExpertsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpertsController>(
      () => ExpertsController(),
    );
  }
}
