import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:golf_score_card/app/modules/create_match/controllers/create_match_controller.dart';
import 'package:golf_score_card/app/routes/app_pages.dart';
import 'package:golf_score_card/app/widgets/custom_button.dart';
import 'package:hugeicons/hugeicons.dart';

class ScorecardController extends GetxController {

  List<String> defaultPlayers = [];
  List<Player> players = [];
  late TabController tabController;
  late MatchType matchType;
  var isDotEnabled = false.obs;
  var currentTabIndex = 0.obs;
  var count = 0.obs;
  RxList<String> selectedPlayers = <String>[].obs;
  Rx<RangeValues> selectedHoleRange = RangeValues(0, 0).obs;
  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments['type'] as MatchType;
    var args2 = Get.arguments['info'] as MatchInfo;
    // defaultPlayers = args2.toList();
    matchType = args;
    // for(var name in defaultPlayers){
    //   players.add(Player(name: name));
    // }
    players = args2.players;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }


  // List<DataColumn> buildColumns() {
  //   List<DataColumn> columns = [const DataColumn(label: SizedBox(width: 30, child: Text('Hole')))];
  //
  //   for (var player in players) {
  //     columns.add(DataColumn(label: Text(player.name)));
  //   }
  //   return columns;
  // }

  List<DataColumn> buildColumns({required bool isLandscape}) {
    if (isLandscape) {
      int currentTabIndex = tabController.index;
      int startHole = currentTabIndex == 1 ? 9 : 0;
      int endHole = currentTabIndex == 0 ? 9 : 18;
      List<DataColumn> columns = [const DataColumn(label: Text('Player'))];
      for (int hole = startHole; hole < endHole; hole++) {
        columns.add(DataColumn(label: Text('H${hole + 1}')));
      }
      columns.add(const DataColumn(label: Text('Total')));
      columns.add(const DataColumn(label: Text('Dots')));
      return columns;
    } else {
      // Portrait - original layout
      List<DataColumn> columns = [const DataColumn(label: SizedBox(width: 30, child: Text('Hole')))];
      for (var player in players) {
        columns.add(DataColumn(label: Text(player.name)));
      }
      return columns;
    }
  }


  List<DataRow> buildRows({required bool isLandscape}) {
    var currentTabIndex = tabController.index;
    int startHole =  matchType == MatchType.open ? currentTabIndex == 1 ? 9 : 0 : 0;
    int endHole = matchType == MatchType.open ? currentTabIndex == 0 ? 9 : 18 : currentTabIndex < 2 ? 9 : 18;
    if (isLandscape) {
      // Players as rows, Holes as columns
      // int currentTabIndex = tabController.index;
      // int startHole = currentTabIndex == 1 ? 9 : 0;
      // int endHole = currentTabIndex == 0 ? 9 : 18;
      return players.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        List<DataCell> cells = [DataCell(Text(player.name))];
        int total = 0;
        int totalDots = 0;
        final isEven = index % 2 == 0;
        for (int hole = startHole; hole < endHole; hole++) {
          int score = 0;
          int dot = 0;
          if(matchType == MatchType.open){
            score = player.scores[hole];
            dot = player.dots[hole];
          }
          else{
            if(currentTabIndex == 0){
              score = player.front9Scores[hole];
              dot = player.front9Dots[hole];
            }
            else if(currentTabIndex == 1){
              score = player.back9Scores[hole];
              dot = player.back9Dots[hole];
            }
            else{
              score = player.all18Scores[hole];
              dot = player.all18Dots[hole];
            }
          }
          final isSelected = selectedPlayers.contains(player.name);
          final isInRange = (hole >= selectedHoleRange.value.start - 1) && (hole <= selectedHoleRange.value.end - 1);
          final shouldHighlight = isSelected && isInRange;

          total += score;
          totalDots += dot;
          cells.add(DataCell(InkWell(
            onTap: () => _showScoreDialog(player, hole),
            child: Container(
              color: shouldHighlight ? Colors.yellow.withValues(alpha: .4) : null,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              constraints: BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDotEnabled.value)
                    Text('●' * (matchType == MatchType.open ? player.dots[hole] : (currentTabIndex == 0 ? player.front9Dots[hole] : currentTabIndex == 1 ? player.back9Dots[hole] : player.all18Dots[hole])), style: const TextStyle(fontSize: 10, color: Color(0xff44673E))),
                  Text(score == 0 ? '-' : score.toString(), style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          )));
        }
        // Total Cell
        cells.add(DataCell(Text(
          total.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )));
        cells.add(DataCell(Text(totalDots.toString(), style: const TextStyle(fontWeight: FontWeight.bold))));
        return DataRow(cells: cells, color: WidgetStatePropertyAll(isEven ? Color(0xffEBFFE8) : Color(0xffF3F3F3)));
      }).toList();
    }
    else {
      // Portrait - original layout
      List<DataRow> rows = [];
      // var currentTabIndex = tabController.index;
      // int startHole = currentTabIndex == 1 ? 9 : 0;
      // int endHole = currentTabIndex == 0 ? 9 : 18;

      for (int hole = startHole; hole < endHole; hole++) {
        List<DataCell> cells = [DataCell(Text('${hole + 1}'))];

        for (var player in players) {
          int score = 0;
          if(matchType == MatchType.open) {
            score = player.scores[hole];
          } else{
            if(currentTabIndex == 0){
              score = player.front9Scores[hole];
            }
            else if(currentTabIndex == 1){
              score = player.back9Scores[hole];
            }
            else{
              score = player.all18Scores[hole];
            }
          }
          final isSelected = selectedPlayers.contains(player.name);
          final isInRange = (hole >= selectedHoleRange.value.start - 1) && (hole <= selectedHoleRange.value.end - 1);
          final shouldHighlight = isSelected && isInRange;

          cells.add(DataCell(InkWell(
            onTap: () => _showScoreDialog(player, hole),
            child: Container(
              color: shouldHighlight ? Colors.yellow.withValues(alpha: .4) : null,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              constraints: const BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDotEnabled.value)
                    Text('●' * (matchType == MatchType.open ? player.dots[hole] : (currentTabIndex == 0 ? player.front9Dots[hole] : currentTabIndex == 1 ? player.back9Dots[hole] : player.all18Dots[hole])), style: const TextStyle(fontSize: 10, color: Color(0xff44673E))),
                  Text(score == 0 ? '-' : score.toString(), style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          )));
        }

        rows.add(DataRow(cells: cells, color: WidgetStatePropertyAll(rows.length.isOdd ? Color(0xffEBFFE8) : Color(0xffF3F3F3))));
      }

      // Total row
      List<DataCell> totalCells = [const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold)))];
      for (var player in players) {
        int total = 0;
        int totalDots = 0;
        int start = matchType == MatchType.open ? currentTabIndex == 1 ? 9 : 0 : 0;
        int end = matchType == MatchType.open ? currentTabIndex == 0 ? 9 : 18 : currentTabIndex < 2 ? 9 : 18;

        for (int i = start; i < end; i++) {
          if(matchType == MatchType.open){
            total += player.scores[i];
            totalDots += player.dots[i];
          }
          else{
            if(currentTabIndex == 0){
              total += player.front9Scores[i];
              totalDots += player.front9Dots[i];
            }
            else if(currentTabIndex == 1){
              total += player.back9Scores[i];
              totalDots += player.back9Dots[i];
            }
            else{
              total += player.all18Scores[i];
              totalDots += player.all18Dots[i];
            }
          }
        }

        totalCells.add(DataCell(
          Container(
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints.expand(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDotEnabled.value && totalDots > 0)
                  Text(
                    'Dots: $totalDots',
                    style: const TextStyle(fontSize: 12, color: Color(0xff44673E)),
                  ),
                Text(
                  total.toString(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ));
      }
      rows.add(DataRow(cells: totalCells, color: WidgetStatePropertyAll(Color(0xffAAF29F))));
    return rows;
  }
  }


  // List<DataRow> buildRows() {
  //   List<DataRow> rows = [];
  //   var currentTabIndex = tabController.index;
  //   int startHole = currentTabIndex == 1 ? 9 : 0;
  //   int endHole = currentTabIndex == 0 ? 9 : (currentTabIndex == 1 ? 18 : 18);
  //
  //   for (int hole = startHole; hole < endHole; hole++) {
  //     List<DataCell> cells = [DataCell(Text('${hole + 1}'))];
  //
  //     for (var player in players) {
  //       final score = player.scores[hole];
  //       final isSelected = selectedPlayers.contains(player.name);
  //       final isInRange = score >= selectedScoreRange.value.start && score <= selectedScoreRange.value.end;
  //
  //       final shouldHighlight = isSelected && isInRange;
  //       cells.add(DataCell(
  //         InkWell(
  //           onTap: () => _showScoreDialog(player, hole),
  //           child: Container(
  //             constraints: BoxConstraints.expand(),
  //             color: shouldHighlight ? Colors.yellow.withValues(alpha: 0.4) : null, // background color
  //             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 if (isDotEnabled.value && player.dots[hole] > 0)
  //                   Text(
  //                     '●' * player.dots[hole],
  //                     style: const TextStyle(fontSize: 10, color: Colors.blue),
  //                   ),
  //                 Text(
  //                   score == 0 ? '-' : score.toString(),
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ),
  //       ));
  //     }
  //
  //     rows.add(DataRow(cells: cells));
  //   }
  //   // Total row
  //   List<DataCell> totalCells = [const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold)))];
  //   for (var player in players) {
  //     int total = 0;
  //     int totalDots = 0;
  //     int start = currentTabIndex == 1 ? 9 : 0;
  //     int end = currentTabIndex == 0 ? 9 : 18;
  //
  //     for (int i = start; i < end; i++) {
  //       total += player.scores[i];
  //       totalDots += player.dots[i];
  //     }
  //
  //     totalCells.add(DataCell(
  //       Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           if (isDotEnabled.value && totalDots > 0)
  //             Text(
  //               'Dots: $totalDots',
  //               style: const TextStyle(fontSize: 12, color: Colors.blue),
  //             ),
  //           Text(
  //             total.toString(),
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //     ));
  //   }
  //   rows.add(DataRow(cells: totalCells));
  //   return rows;
  // }

  void _showScoreDialog(Player player, int hole) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${player.name} - Hole ${hole + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter Score:'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                children: List.generate(10, (index) {
                  int score = index + 1;
                  return ElevatedButton(
                    onPressed: () {
                      var currentTabIndex = tabController.index;
                        if(matchType == MatchType.open){
                          player.scores[hole] = score;
                        }
                        else{
                          if(currentTabIndex == 0){
                            player.front9Scores[hole] = score;
                          }
                          else if(currentTabIndex == 1){
                            player.back9Scores[hole] = score;
                          }
                          else{
                            player.all18Scores[hole] = score;
                          }
                        }
                        count.value++;
                      Navigator.of(context).pop();
                      if (isDotEnabled.value) {
                        _showDotsDialog(player, hole);
                      }
                    },
                    child: Text(score.toString()),
                  );
                }),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  label: Text('Custom Value')
                ),
                onFieldSubmitted: (val){
                  var number = int.tryParse(val) ?? 0;
                  var currentTabIndex = tabController.index;
                  if(matchType == MatchType.open){
                    player.scores[hole] = number;
                  }
                  else{
                    if(currentTabIndex == 0){
                      player.front9Scores[hole] = number;
                    }
                    else if(currentTabIndex == 1){
                      player.back9Scores[hole] = number;
                    }
                    else{
                      player.all18Scores[hole] = number;
                    }
                  }
                  count.value++;
                  Navigator.of(context).pop();
                  if (isDotEnabled.value) {
                    _showDotsDialog(player, hole);
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _showDotsDialog(Player player, int hole) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${player.name} - Hole ${hole + 1} Dots'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter Dots (0-6):'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(7, (index) {
                  return ElevatedButton(
                    onPressed: () {
                        var currentTabIndex = tabController.index;
                        if(matchType == MatchType.open){
                          player.dots[hole] = index;
                        }
                        else{
                          if(currentTabIndex == 0){
                            player.front9Dots[hole] = index;
                          }
                          else if(currentTabIndex == 1){
                            player.back9Dots[hole] = index;
                          }
                          else{
                            player.all18Dots[hole] = index;
                          }
                        }
                        count.value++;
                      Navigator.of(context).pop();
                    },
                    child: Text(index.toString()),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void showPlayersToHighlight(int value, bool isLandscaped){
    selectedPlayers.clear();
    switch(value){
      case 0:
        selectedHoleRange.value = const RangeValues(1, 6);
        break;
      case 1:
        selectedHoleRange.value = const RangeValues(7, 12);
        break;
      case 2:
        selectedHoleRange.value = const RangeValues(13, 18);
        break;
      default:
        Get.toNamed(Routes.RESULT, arguments: players);
        return;
    }
    if(isLandscaped){
      Get.dialog(Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Gap(20),
                Text('Select players to highlight',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  ),),
                Gap(10),
                ...List.generate(players.length, (index) => ListTile(
                  title: Row(
                    children: [
                      HugeIcon(icon: HugeIcons.strokeRoundedProfile, color: Color(0xff87CD7C)),
                      Text('Player ${index + 1}'),
                    ],
                  ),
                  subtitle: Text(players[index].name),
                  leading: Obx(() => Checkbox.adaptive(
                      value: selectedPlayers.contains(players[index].name),
                      onChanged: (val){
                        if (val == true) {
                          selectedPlayers.add(players[index].name);
                        } else {
                          selectedPlayers.remove(players[index].name);
                        }
                      }),
                  ),
                )),
                Gap(15),
                CustomButton(onTap: () => Get.back(), width: 129, height: 43, text: 'Done'),
              ],
            ),
          ),
        ),
      ));
    }
    else{
      showModalBottomSheet(context: Get.context!, builder: (_) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Gap(20),
            Text('Select players to highlight',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),),
            Gap(10),
            ...List.generate(players.length, (index) => ListTile(
              title: Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedUser02, color: Color(0xff87CD7C)),
                  Gap(5),
                  Text('Player ${index + 1}'),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(players[index].name),
              ),
              leading: Obx(() => Checkbox.adaptive(
                  side: BorderSide(color: Color(0xff87CD7C), width: 1.2),
                  checkColor: Colors.white,
                  activeColor: Color(0xff87CD7C),
                  value: selectedPlayers.contains(players[index].name),
                  onChanged: (val){
                    if (val == true) {
                      selectedPlayers.add(players[index].name);
                    } else {
                      selectedPlayers.remove(players[index].name);
                    }
                  }),
              ),
            )),
            Gap(15),
            CustomButton(onTap: () => Get.back(), width: 129, height: 43, text: 'Done'),
          ],
        ),
      ));
    }
  }

  TextStyle getScoreTextStyle(Player player, int hole) {
    final score = player.scores[hole];
    final range = selectedHoleRange.value;
    final isSelected = selectedPlayers.contains(player.name);

    if (isSelected && score >= range.start && score <= range.end) {
      return const TextStyle(
        fontSize: 16,
        backgroundColor: Colors.yellowAccent,
      );
    }

    return const TextStyle(fontSize: 16);
  }


}


class Player {
  String name;
  List<int> scores;
  List<int> dots;
  List<int> front9Scores;
  List<int> back9Scores;
  List<int> all18Scores;
  List<int> front9Dots;
  List<int> back9Dots;
  List<int> all18Dots;
  Player({required this.name}) :
        scores = List.filled(18, 0),
        dots = List.filled(18, 0),
        front9Scores = List.filled(9, 0),
        back9Scores = List.filled(9, 0),
        all18Scores = List.filled(18, 0),
        front9Dots = List.filled(9, 0),
        back9Dots = List.filled(9, 0),
        all18Dots = List.filled(18, 0);
}

class PlayerMatch{
  String id;
  Player player1;
  Player player2;
  PlayerMatch({required this.id, required this.player1, required this.player2});
}

enum MatchPreference{
  single,
  match
}

class MatchInfo{
  final MatchPreference preference;
  final List<Player> players;
  final List<PlayerMatch>? matches;

  MatchInfo({required this.players, required this.preference, this.matches});
}