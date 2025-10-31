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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ Main Match Result Table
            Text(
              "Main Match Result",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            MatchResultTable(players: controller.players),

            const SizedBox(height: 24),

            // ✅ Press Matches Result Section
            if (controller.pressMatches.isNotEmpty) ...[
              Text(
                "Press Matches Result",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // ✅ Yaha ab custom PressMatchResultTable use karenge
              PressMatchResultTable(
                pressMatches: controller.pressMatches,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
