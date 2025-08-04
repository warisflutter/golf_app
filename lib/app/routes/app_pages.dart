import 'package:get/get.dart';

import '../modules/create_match/bindings/create_match_binding.dart';
import '../modules/create_match/views/create_match_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/result/bindings/result_binding.dart';
import '../modules/result/views/result_view.dart';
import '../modules/scorecard/bindings/scorecard_binding.dart';
import '../modules/scorecard/views/scorecard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_MATCH,
      page: () => const CreateMatchView(),
      binding: CreateMatchBinding(),
    ),
    GetPage(
      name: _Paths.SCORECARD,
      page: () => const ScorecardView(),
      binding: ScorecardBinding(),
    ),
    GetPage(
      name: _Paths.RESULT,
      page: () => const ResultView(),
      binding: ResultBinding(),
    ),
  ];
}
