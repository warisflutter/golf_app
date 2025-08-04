import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../scorecard/controllers/scorecard_controller.dart';

class ResultController extends GetxController {
  //TODO: Implement ResultController
  List<Player> players = [];
  int count = 0;

  @override
  void onInit() {
    super.onInit();
    players = Get.arguments as List<Player>;
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
        status.add(''); // Hole not played
        continue;
      }

      if (aScore < bScore) {
        up++;
      } else if (aScore > bScore){
        up--;
      }

      if (up > 0) {
        status.add('UP $up');
      } else if (up < 0) {
        status.add('DOWN ${-up}');
      }
      else {
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
      return Text(status); // fallback
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
              DataColumn(label: Text('H${i + 1}')),
              DataColumn(label: Text('F9')),
              DataColumn(label: Text('B9'))
          ],
          rows: pairs.map((pair) {
            final playerA = pair[0];
            final playerB = pair[1];
            final result = calculateMatchStatus(playerA, playerB);
            return DataRow(
              cells: [
                DataCell( Text.rich(
                    TextSpan(
                        text: '${playerA.name} ',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600
                        ),
                        children: [
                          TextSpan(
                              text: 'vs',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300)
                          ),
                          TextSpan(
                              text: ' ${playerB.name}',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600
                              )
                          )
                        ]
                    )
                ),),
                for (int i = 0; i < 18; i++) DataCell(_buildResultCell(result[i])),
                DataCell(_buildResultCell(result[8])),
                DataCell(_buildResultCell(result[17])),
              ],
            );
          }).toList(),
        ),
      ),
    );




    // return ListView.builder(
    //   itemCount: pairs.length,
    //   itemBuilder: (context, index) {
    //     final playerA = pairs[index][0];
    //     final playerB = pairs[index][1];
    //     final result = calculateMatchStatus(playerA, playerB);
    //     return Card(
    //       margin: const EdgeInsets.all(12),
    //       child: Padding(
    //         padding: const EdgeInsets.all(16),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text.rich(
    //               TextSpan(
    //                 text: '${playerA.name} ',
    //                 style: TextStyle(
    //                   fontSize: 20,
    //                   fontWeight: FontWeight.w600
    //                 ),
    //                 children: [
    //                   TextSpan(
    //                     text: 'vs',
    //                     style: TextStyle(color: Colors.red, fontWeight: FontWeight.w300)
    //                   ),
    //                   TextSpan(
    //                     text: ' ${playerB.name}',
    //                     style: TextStyle(
    //                       fontSize: 12,
    //                       fontWeight: FontWeight.w600
    //                     )
    //                   )
    //                 ]
    //               )
    //             ),
    //             // Text(
    //             //   '${playerA.name} vs ${playerB.name}',
    //             //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //             // ),
    //             // const SizedBox(height: 12),
    //             SizedBox(
    //               width: Get.width,
    //               child: DataTable(
    //                 columns: const [
    //                   DataColumn(label: Text('Hole')),
    //                   DataColumn(label: Text('Result')),
    //                 ],
    //                 rows: List<DataRow>.generate(
    //                   18,
    //                       (i) => DataRow(
    //                     cells: [
    //                       DataCell(Text('Hole ${i + 1}')),
    //                       DataCell(_buildResultCell(result[i])),
    //                     ],
    //                   ),
    //                 )
    //                   ..add(DataRow(cells: [
    //                     const DataCell(Text('Front 9 Summary', style: TextStyle(fontWeight: FontWeight.bold))),
    //                     DataCell(_buildResultCell(result[8])),
    //                   ]))
    //                   ..add(DataRow(cells: [
    //                     const DataCell(Text('Back 9 Summary', style: TextStyle(fontWeight: FontWeight.bold))),
    //                     DataCell(_buildResultCell(result[17])),
    //                   ]))
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}

