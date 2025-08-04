import 'package:get/get.dart';

import '../controllers/create_match_controller.dart';

class CreateMatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateMatchController>(
      () => CreateMatchController(),
    );
  }
}
