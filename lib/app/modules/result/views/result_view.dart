import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('Key${controller.count}'),
      appBar: AppBar(
        title: const Text('ResultView'),
        centerTitle: true,
      ),
      body: MatchResultTable(players: controller.players),
    );
  }
}
