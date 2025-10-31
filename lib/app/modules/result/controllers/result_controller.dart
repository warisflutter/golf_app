import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../scorecard/controllers/scorecard_controller.dart';

class ResultController extends GetxController {
  //TODO: Implement ResultController
  List<Player> players = [];
  List<PressMatchModel> pressMatches = []; // 👈 add this
  int count = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    players = args["players"] as List<Player>;
    pressMatches = args["pressMatches"] as List<PressMatchModel>;
    generateResults(players);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  List<List<Player>> getPlayerPairs(List<Player> players) {
    List<List<Player>> pairs = [];
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        pairs.add([players[i], players[j]]);
      }
    }
    return pairs;
  }

  List<String> calculateMatchStatus(Player a, Player b) {
    int up = 0;
    List<String> status = [];

    for (int i = 0; i < 18; i++) {
      final aScore = a.scores[i];
      final bScore = b.scores[i];

      if (aScore == 0 || bScore == 0) {
        status.add(''); // Hole not played
        continue;
      }

      if (aScore < bScore) { up++;}
      else if (aScore > bScore) {up--;}

      if (up > 0) { status.add('Up $up'); }
      else if (up < 0) {status.add('Down ${-up}');}
      else {status.add('Even');}
    }

    return status;
  }

  void generateResults(List<Player> players) {
    final pairs = getPlayerPairs(players);

    for (var pair in pairs) {
      final playerA = pair[0];
      final playerB = pair[1];

      final result = calculateMatchStatus(playerA, playerB);

      if(kDebugMode) { print('${playerA.name} vs ${playerB.name}:'); }
      for (int i = 0; i < 9; i++) {
        if(kDebugMode) { print('Hole ${i + 1}: ${result[i]}'); }
      }
      if(kDebugMode) print('Front 9 Result: ${result[8]}');

      for (int i = 9; i < 18; i++) {
        if(kDebugMode) print('Hole ${i + 1}: ${result[i]}');
      }
      if(kDebugMode){
        print('Back 9 Result: ${result[17]}');
        print('---');
      }
    }
  }
}

class MatchResultTable extends StatelessWidget {
  final List<Player> players;

  const MatchResultTable({super.key, required this.players});

  List<List<Player>> getPlayerPairs(List<Player> players) {
    List<List<Player>> pairs = [];
    for (int i = 0; i < players.length; i++) {
      for (int j = 0; j < players.length; j++) {
        if (i != j) {
          pairs.add([players[i], players[j]]);
        }
      }
    }
    return pairs;
  }

  List<String> calculateMatchStatus(Player a, Player b) {
    int up = 0;
    List<String> status = [];

    for (int i = 0; i < 18; i++) {
      final aScore = a.scores[i];
      final bScore = b.scores[i];

      if (aScore == 0 || bScore == 0) {
        status.add('');
        continue;
      }

      if (aScore < bScore) up++;
      else if (aScore > bScore) up--;

      if (up > 0) {
        status.add('UP $up');
      } else if (up < 0) {
        status.add('DOWN ${-up}');
      } else {
        status.add('AS');
      }
    }

    return status;
  }

  Widget _buildResultCell(String status) {
    if (status == 'AS') {
      return const Text('AS', style: TextStyle(fontWeight: FontWeight.bold));
    } else if (status.contains('UP')) {
      final parts = status.split('UP');
      return Row(
        children: [
          Text(parts[1], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
        ],
      );
    } else if (status.contains('DOWN')) {
      final parts = status.split('DOWN');
      return Row(
        children: [
          Text(parts[1], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
        ],
      );
    } else {
      return Text(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pairs = getPlayerPairs(players);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 15,
          columns: [
            const DataColumn(label: Text('Match')),
            for (int i = 0; i < 18; i++)
              DataColumn(label: Text('${i + 1}')),
            const DataColumn(label: Text('F9')),
            const DataColumn(label: Text('B9')),
          ],
          rows: pairs.map((pair) {
            final playerA = pair[0];
            final playerB = pair[1];
            final result = calculateMatchStatus(playerA, playerB);

            return DataRow(
              cells: [
                DataCell(
                  Text.rich(
                    TextSpan(
                      text: '${playerA.name} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(
                          text: 'vs ',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          text: playerB.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (int i = 0; i < 18; i++) DataCell(_buildResultCell(result[i])),
                DataCell(_buildResultCell(result[8])),
                DataCell(_buildResultCell(result[17])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PressMatchResultTable extends StatelessWidget {
  final List<PressMatchModel> pressMatches;

  const PressMatchResultTable({super.key, required this.pressMatches});

  List<String> calculatePressStatus(Player a, Player b, int startHole) {
    int up = 0;
    List<String> status = [];

    for (int i = startHole; i < 18; i++) {
      final aScore = a.pressScores[i];
      final bScore = b.pressScores[i];

      if (aScore == 0 || bScore == 0) {
        status.add('');
        continue;
      }

      if (aScore < bScore) up++;
      else if (aScore > bScore) up--;

      if (up > 0) {
        status.add('UP $up');
      } else if (up < 0) {
        status.add('DOWN ${-up}');
      } else {
        status.add('AS');
      }
    }

    return status;
  }

  Widget _buildResultCell(String status, {bool disabled = false}) {
    if (disabled) {
      return const SizedBox.shrink(); // ⚡ invisible when disabled
    }

    TextStyle style = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.black,
    );

    if (status == 'AS') {
      return Text('AS', style: style);
    } else if (status.contains('UP')) {
      final parts = status.split('UP');
      return Row(
        children: [
          Text(parts[1], style: style),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
        ],
      );
    } else if (status.contains('DOWN')) {
      final parts = status.split('DOWN');
      return Row(
        children: [
          Text(parts[1], style: style),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
        ],
      );
    } else {
      return Text(status, style: style);
    }
  }

  Widget _buildMatchLabel(String playerA, String playerB) {
    return Text.rich(
      TextSpan(
        text: '$playerA ',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          const TextSpan(
            text: 'vs ',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextSpan(
            text: playerB,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pressMatches.isEmpty) {
      return const Center(child: Text("No Press Matches"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < pressMatches.length; i++) ...[
          Text(
            "Press Match ${i + 1}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 15,
              columns: [
                const DataColumn(label: Text('Match')),
                for (int h = pressMatches[i].holeIndex + 1; h < 18; h++)
                  DataColumn(
                    label: Builder(builder: (_) {
                      // check if next press match exists
                      int? nextPressHole = i + 1 < pressMatches.length
                          ? pressMatches[i + 1].holeIndex + 1
                          : null;

                      bool disabled = nextPressHole != null && h >= nextPressHole;

                      return Text(
                        "${h + 1}",
                        style: TextStyle(
                          color: disabled ? Colors.grey : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                const DataColumn(label: Text("F9")),
                const DataColumn(label: Text("B9")),
              ],
              rows: pressMatches[i].opponents.expand((opponent) {
                final player = pressMatches[i].player;

                final result1 = calculatePressStatus(
                  player,
                  opponent,
                  pressMatches[i].holeIndex + 1,
                );

                final result2 = calculatePressStatus(
                  opponent,
                  player,
                  pressMatches[i].holeIndex + 1,
                );

                // Find next press match start hole (if exists)
                int? nextPressHole = i + 1 < pressMatches.length
                    ? pressMatches[i + 1].holeIndex + 1
                    : null;

                bool isDisabledHole(int holeNumber) {
                  if (nextPressHole != null && holeNumber >= nextPressHole) {
                    return true; // grey out + invisible
                  }
                  return false;
                }

                Widget getF9(List<String> result) {
                  int f9Index = 8 - pressMatches[i].holeIndex;
                  if (f9Index >= 0 && f9Index < result.length) {
                    return _buildResultCell(
                      result[f9Index],
                      disabled: isDisabledHole(9),
                    );
                  }
                  return const Text('');
                }

                Widget getB9(List<String> result) {
                  int b9Index = 17 - pressMatches[i].holeIndex;
                  if (b9Index >= 0 && b9Index < result.length) {
                    return _buildResultCell(
                      result[b9Index],
                      disabled: isDisabledHole(18),
                    );
                  }
                  return const Text('');
                }

                return [
                  DataRow(
                    cells: [
                      DataCell(_buildMatchLabel(player.name, opponent.name)),
                      for (int idx = 0; idx < result1.length; idx++)
                        DataCell(
                          _buildResultCell(
                            result1[idx],
                            disabled: isDisabledHole(
                              pressMatches[i].holeIndex + 1 + idx,
                            ),
                          ),
                        ),
                      DataCell(getF9(result1)),
                      DataCell(getB9(result1)),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(_buildMatchLabel(opponent.name, player.name)),
                      for (int idx = 0; idx < result2.length; idx++)
                        DataCell(
                          _buildResultCell(
                            result2[idx],
                            disabled: isDisabledHole(
                              pressMatches[i].holeIndex + 1 + idx,
                            ),
                          ),
                        ),
                      DataCell(getF9(result2)),
                      DataCell(getB9(result2)),
                    ],
                  ),
                ];
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ]
      ],
    );
  }
}
