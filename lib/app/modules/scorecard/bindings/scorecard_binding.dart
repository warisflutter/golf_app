import 'package:get/get.dart';

import '../controllers/scorecard_controller.dart';

class ScorecardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScorecardController>(
      () => ScorecardController(),
    );
  }
}
