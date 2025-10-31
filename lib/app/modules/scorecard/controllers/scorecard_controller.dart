import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:golf_score_card/app/modules/create_match/controllers/create_match_controller.dart';
import 'package:golf_score_card/app/routes/app_pages.dart';
import 'package:golf_score_card/app/widgets/custom_button.dart';
import 'package:hugeicons/hugeicons.dart';

class ScorecardController extends GetxController {

  // Controller fields (as you already have)
  RxList<PressMatchModel> pressMatches = <PressMatchModel>[].obs;
  Rx<PressMatchModel?> activePressMatch = Rx<PressMatchModel?>(null);
  Rx<Offset> pressButtonPosition = const Offset(300, 200).obs;

// Helper: first press set karne ke liye (initial opponents ke saath)
  void setActivePress({
    required Player player,
    required int holeIndex,
    required List<Player> opponents,
    Offset? initialPosition,
  }) {
    final press = PressMatchModel(
      player: player,
      holeIndex: holeIndex,
      opponents: opponents,
      initialPosition: initialPosition,
    );
    activePressMatch.value = press;
    pressMatches.add(press);
  }
  void clearActivePress() {
    activePressMatch.value = null;
  }
  void showPressDialog(Player player, int holeIndex) {
    _showPressDialog(player, holeIndex);
  }

  var dragX = 10.0.obs;
  var dragY = 80.0.obs;

  List<String> defaultPlayers = [];
  List<Player> players = [];
  late TabController tabController;
  late MatchType matchType;
  var isDotEnabled = false.obs;
  var currentTabIndex = 0.obs;
  var count = 0.obs;
  var disabledFromHole = RxnInt();
  final disableFromHoleIndex = (-1).obs; // -1 means nothing disabled
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

  List<DataColumn> buildColumns({required bool isLandscape}) {
    if (isLandscape) {
      int currentTabIndex = tabController.index;
      int startHole = currentTabIndex == 1 ? 9 : 0;
      int endHole = currentTabIndex == 0 ? 9 : 18;
      List<DataColumn> columns = [const DataColumn(label: Text('Player'))];
      for (int hole = startHole; hole < endHole; hole++) {
        columns.add(DataColumn(label: Text('${hole + 1}')));
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

  int get currentHole {
    // Max hole jaha tak score dala gaya
    int maxHole = 0;
    for (var player in players) {
      for (int i = 0; i < 18; i++) {
        if (player.scores[i] > 0) {
          maxHole = i + 1;
        }
      }
    }
    return maxHole;
  }

  int getPressCurrentHole(List<Player> pressPlayers, int startHole) {
    int maxHole = startHole;
    for (var player in pressPlayers) {
      for (int i = startHole; i < 18; i++) {
        if (player.pressScores[i] > 0) {
          maxHole = i + 1;
        }
      }
    }
    return maxHole;
  }

  bool shouldShowPressButtonForMatch(
      Player player,
      int holeIndex,
      PressMatchModel pressMatch,
      ) {
    final pressPlayers = [pressMatch.player, ...pressMatch.opponents];

    // ✅ Har match apne startHole se hi current hole dekhega
    int pressCurrentHole = getPressCurrentHole(pressPlayers, pressMatch.holeIndex);
    if (holeIndex != pressCurrentHole - 1) return false;

    // ✅ Agar next hole already fill hai to button mat dikhao
    if (pressCurrentHole < 18) {
      for (var p in pressPlayers) {
        if (p.pressScores[pressCurrentHole] > 0) return false;
      }
    }

    // ✅ DOWN by 2 rule → is match ke startHole se calc karo
    for (var opponent in pressPlayers) {
      if (opponent == player) continue;

      final result = _calculatePressStatus(
        pressScoresList(player),
        pressScoresList(opponent),
        pressMatch.holeIndex, // 👈 Har match ka apna startHole
      );

      final status = result[holeIndex];
      if (status.startsWith("DOWN")) {
        final downCount = int.tryParse(status.split(" ")[1]) ?? 0;
        if (downCount >= 1) return true;
      }
    }

    return false;
  }

  bool shouldShowPressButton(
      Player player,
      int holeIndex, {
        bool isPressMatch = false,
        List<Player>? pressPlayers,
        PressMatchModel? pressMatch,
      }) {
    if (!isPressMatch) {
      // ---------- Main Match ----------
      if (holeIndex != currentHole - 1) return false;

      if (currentHole < 18) {
        for (var p in players) {
          if (p.scores[currentHole] > 0) return false;
        }
      }

      for (var opponent in players) {
        if (opponent == player) continue;
        final result = _calculateMatchStatus(player, opponent);
        final status = result[holeIndex];
        if (status.startsWith("DOWN")) {
          final downCount = int.tryParse(status.split(" ")[1]) ?? 0;
          if (downCount >= 1) return true;
        }
      }
      return false;
    } else {
      // ---------- Press Match ----------
      if (pressMatch == null) return false;
      return shouldShowPressButtonForMatch(player, holeIndex, pressMatch);
    }
  }

  List<String> _calculateMatchStatus(Player a, Player b) {
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

      if (up > 0) status.add('UP $up');
      else if (up < 0) status.add('DOWN ${-up}');
      else status.add('AS');
    }

    return status;
  }

  List<String> _calculatePressStatus(
      List<int> aScores,
      List<int> bScores,
      int startHole,
      ) {
    int up = 0;
    List<String> status = [];

    for (int i = 0; i < 18; i++) {
      if (i < startHole) {
        status.add('');
        continue;
      }

      final aScore = aScores[i];
      final bScore = bScores[i];

      if (aScore == 0 || bScore == 0) {
        status.add('');
        continue;
      }

      // ✅ Jis hole pe press shuru hua, usko hamesha "AS" set karo
      if (i == startHole) {
        up = 0;
        status.add("AS");
        continue;
      }

      // ✅ Ab startHole ke baad normal calculation chalegi
      if (aScore < bScore) {
        up++;
      } else if (aScore > bScore) {
        up--;
      }

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

  List<DataRow> buildRows({required bool isLandscape}) {
    var currentTabIndex = tabController.index;
    int startHole = matchType == MatchType.open ? currentTabIndex == 1 ? 9 : 0 : 0;
    int endHole = matchType == MatchType.open ? currentTabIndex == 0 ? 9 : 18 : currentTabIndex < 2 ? 9 : 18;

    if (isLandscape) {
      return players.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        List<DataCell> cells = [DataCell(Text(player.name))];
        int total = 0;
        int totalDots = 0;
        final isEven = index % 2 == 0;

        for (int hole = startHole; hole < endHole; hole++) {
          final isDisabled = disabledFromHole.value != null &&
              hole >= disabledFromHole.value!;

          int score = 0;
          int dot = 0;
          if (matchType == MatchType.open) {
            score = player.scores[hole];
            dot = player.dots[hole];
          } else {
            if (currentTabIndex == 0) {
              score = player.front9Scores[hole];
              dot = player.front9Dots[hole];
            } else if (currentTabIndex == 1) {
              score = player.back9Scores[hole];
              dot = player.back9Dots[hole];
            } else {
              score = player.all18Scores[hole];
              dot = player.all18Dots[hole];
            }
          }

          final isSelected = selectedPlayers.contains(player.name);
          final isInRange = (hole >= selectedHoleRange.value.start - 1) &&
              (hole <= selectedHoleRange.value.end - 1);
          final shouldHighlight = isSelected && isInRange;

          total += score;
          totalDots += dot;

          cells.add(
            DataCell(
              InkWell(
                onTap: isDisabled ? null : () => _showScoreDialog(player, hole),
                child: Container(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : (shouldHighlight ? Colors.yellow.withOpacity(0.4) : null),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  constraints: const BoxConstraints.expand(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isDotEnabled.value)
                            Text(
                              '●' *
                                  (matchType == MatchType.open
                                      ? player.dots[hole]
                                      : (currentTabIndex == 0
                                      ? player.front9Dots[hole]
                                      : currentTabIndex == 1
                                      ? player.back9Dots[hole]
                                      : player.all18Dots[hole])),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDisabled
                                    ? Colors.grey
                                    : const Color(0xff44673E),
                              ),
                            ),
                          Text(
                            score == 0 ? '-' : score.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDisabled ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // ✅ Press Button Landscape ke liye
                      if (!isDisabled && shouldShowPressButton(player, hole))
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () {
                                disabledFromHole.value = hole + 1; // 👈 Direct press
                                print('Press: ${player.name} at Hole ${hole + 1}');
                              },
                              child: Text(
                                'Press',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: disabledFromHole.value == hole + 1
                                      ? Colors.grey   // 👈 Press hone ke baad grey
                                      : Colors.green,  // 👈 Normal state
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                disabledFromHole.value = hole + 1;
                                print('Icon Press: ${player.name} at Hole ${hole + 1}');
                                _showPressDialog(player, hole);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  size: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Total Cell
        cells.add(DataCell(Text(
          total.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )));

        cells.add(DataCell(Text(
          totalDots.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        )));

        return DataRow(
          cells: cells,
          color: WidgetStatePropertyAll(
            isEven ? const Color(0xffEBFFE8) : const Color(0xffF3F3F3),
          ),
        );
      }).toList();
    } else {
      List<DataRow> rows = [];

      if (currentTabIndex == 2) {
        // --- Front 9 ---
        rows.add(
          DataRow(
            cells: [
              const DataCell(
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Front 9',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff87CD7C)),
                    ),
                  ),
                ),
              ),
              ...List.generate(players.length, (_) => const DataCell(SizedBox())),
            ],
          ),
        );
      }

      for (int hole = startHole; hole < endHole; hole++) {
        final isDisabled = disabledFromHole.value != null &&
            hole >= disabledFromHole.value!;

        if (currentTabIndex == 2 && hole == 9) {
          rows.add(_buildTotalRow(players, 0, 9, 'Total Front 9'));
          rows.add(
            DataRow(
              cells: [
                const DataCell(
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Back 9',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff87CD7C)),
                      ),
                    ),
                  ),
                ),
                ...List.generate(players.length, (_) => const DataCell(SizedBox())),
              ],
            ),
          );
        }

        List<DataCell> cells = [DataCell(Text('${hole + 1}'))];
        for (var player in players) {
          int score = matchType == MatchType.open
              ? player.scores[hole]
              : currentTabIndex == 0
              ? player.front9Scores[hole]
              : currentTabIndex == 1
              ? player.back9Scores[hole]
              : player.all18Scores[hole];

          final isSelected = selectedPlayers.contains(player.name);
          final isInRange = (hole >= selectedHoleRange.value.start - 1) &&
              (hole <= selectedHoleRange.value.end - 1);
          final shouldHighlight = isSelected && isInRange;

          cells.add(
            DataCell(
              InkWell(
                onTap: isDisabled ? null : () => _showScoreDialog(player, hole),
                child: Container(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : (shouldHighlight
                      ? Colors.yellow.withOpacity(0.4)
                      : null),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  constraints: const BoxConstraints.expand(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isDotEnabled.value)
                            Text(
                              '●' *
                                  (matchType == MatchType.open
                                      ? player.dots[hole]
                                      : (currentTabIndex == 0
                                      ? player.front9Dots[hole]
                                      : currentTabIndex == 1
                                      ? player.back9Dots[hole]
                                      : player.all18Dots[hole])),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDisabled
                                    ? Colors.grey
                                    : const Color(0xff44673E),
                              ),
                            ),
                          Text(
                            score == 0 ? '-' : score.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: isDisabled ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // Press Button
                      if (!isDisabled && shouldShowPressButton(player, hole))
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              final isPressed = disabledFromHole.value == hole + 1;

                              return isPressed
                                  ? GestureDetector(
                                onTap: () {
                                  print('Icon Press: ${player.name} at Hole ${hole + 1}');
                                  _showPressDialog(player, hole); // 👈 Dialog khulega
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    size: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              )
                                  : TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () {
                                  // 👇 Confirmation dialog
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text("Confirmation"),
                                      content: const Text("Are you sure you want to play a press match?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(), // ❌ Cancel
                                          child: const Text("No"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.back(); // close confirmation dialog
                                            disabledFromHole.value = hole + 1; // mark as pressed
                                            print('Press: ${player.name} at Hole ${hole + 1}');
                                            _showPressDialog(player, hole); // open press dialog
                                          },
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Press',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              );
                            }),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        rows.add(
          DataRow(
            cells: cells,
            color: WidgetStatePropertyAll(
              isDisabled
                  ? Colors.grey.shade300
                  : (rows.length.isOdd
                  ? const Color(0xffEBFFE8)
                  : const Color(0xffF3F3F3)),
            ),
          ),
        );
      }

      if (currentTabIndex == 2) {
        rows.add(_buildTotalRow(players, 9, 18, 'Total Back 9'));
      }

      // Existing Final Total Row
      List<DataCell> totalCells = [
        const DataCell(Text('Total All',
            style: TextStyle(fontWeight: FontWeight.bold)))
      ];
      for (var player in players) {
        int total = 0;
        int totalDots = 0;
        int start = matchType == MatchType.open ? currentTabIndex == 1 ? 9 : 0 : 0;
        int end = matchType == MatchType.open ? currentTabIndex == 0 ? 9 : 18 : currentTabIndex < 2 ? 9 : 18;

        for (int i = start; i < end; i++) {
          if (matchType == MatchType.open) {
            total += player.scores[i];
            totalDots += player.dots[i];
          } else {
            if (currentTabIndex == 0) {
              total += player.front9Scores[i];
              totalDots += player.front9Dots[i];
            } else if (currentTabIndex == 1) {
              total += player.back9Scores[i];
              totalDots += player.back9Dots[i];
            } else {
              total += player.all18Scores[i];
              totalDots += player.all18Dots[i];
            }
          }
        }

        totalCells.add(
          DataCell(
            Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isDotEnabled.value && totalDots > 0)
                    Text('Dots: $totalDots',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xff44673E))),
                  Text(
                    total.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      rows.add(DataRow(
          cells: totalCells,
          color: const WidgetStatePropertyAll(Color(0xffAAF29F))));

      return rows;
    }
  }

  DataRow _buildTotalRow(List<Player> players, int start, int end, String label) {
    return DataRow(
      color: const WidgetStatePropertyAll(Color(0xffAAF29F)),
      cells: [
        DataCell(
          Center(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...players.map((player) {
          int score = 0;
          for (int i = start; i < end; i++) {
            if (matchType == MatchType.open) {
              score += player.scores[i];
            } else if (tabController.index == 0) {
              score += player.front9Scores[i];
            } else if (tabController.index == 1) {
              score += player.back9Scores[i];
            } else {
              score += player.all18Scores[i];
            }
          }
          return DataCell(
            Center(
              child: Text(
                score.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<int> pressScoresList(Player p) {
    if (matchType == MatchType.open) return p.pressScores;
    final idx = tabController.index;
    if (idx == 0) return p.pressFront9Scores;
    if (idx == 1) return p.pressBack9Scores;
    return p.pressAll18Scores;
  }

  List<int> pressDotsList(Player p) {
    if (matchType == MatchType.open) return p.pressDots;
    final idx = tabController.index;
    if (idx == 0) return p.pressFront9Dots;
    if (idx == 1) return p.pressBack9Dots;
    return p.pressAll18Dots;
  }

  void _showPressDialog(Player player, int holeIndex) {
    final isFront9 = holeIndex < 9;
    final startHole = holeIndex + 1;
    final endHole = 18;

    final scoreController = Get.find<ScorecardController>();
    final currentActive = scoreController.activePressMatch.value;

    bool wasPressedHere(Player p, int absHole) {
      return scoreController.pressMatches.any(
            (m) => m.pressedAtHole == absHole && m.pressedBy == p, // ✅ sirf initiator k liye true
      );
    }


    List<Player> computeInitialOpponents() {
      final pressPlayers = [
        player,
        ...players.where((opponent) {
          if (opponent == player) return false;
          final statusAtPressedHole = _calculateMatchStatus(player, opponent)[holeIndex];
          return statusAtPressedHole.startsWith("DOWN");
        }),
      ];
      return pressPlayers.where((p) => p != player).toList();
    }

    final List<Player> opponents = (currentActive != null && currentActive.player == player)
        ? currentActive.opponents
        : computeInitialOpponents();

    // ------------------------------------------------
    if (scoreController.activePressMatch.value == null) {
      final firstPress = PressMatchModel(
        player: player,
        holeIndex: holeIndex,
        opponents: opponents,
        isActive: true,
      );

      scoreController.pressMatches.add(firstPress);
      scoreController.pressMatches.refresh();
      scoreController.activePressMatch.value = firstPress;
    }

    // ---------- Helpers ----------
    int? localIndexFor(int absHole) {
      if (matchType == MatchType.open) return absHole;
      final idx = tabController.index;
      if (idx == 0) return (absHole >= 0 && absHole < 9) ? absHole : null;
      if (idx == 1) {
        final li = absHole - 9;
        return (li >= 0 && li < 9) ? li : null;
      }
      return absHole;
    }

    String scoreText(List<int> list, int? li) {
      if (li == null || li < 0 || li >= list.length) return "-";
      final v = list[li];
      return v == 0 ? "-" : "$v";
    }

    Widget scoreWithDots(Player p, int absHole) {
      final scores = pressScoresList(p);
      final dots = pressDotsList(p);
      final li = localIndexFor(absHole);

      return InkWell(
        onTap: () => _showScoreDialog(p, absHole, isPress: true),
        child: Container(
          width: 20, // 👈 fixed width so tap area bada ho
          height: 40, // 👈 fixed height so easy to tap
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isDotEnabled.value &&
                  li != null &&
                  li >= 0 &&
                  li < dots.length &&
                  dots[li] > 0)
                Text(
                  List.generate(dots[li], (_) => "●").join(""),
                  style: const TextStyle(fontSize: 10, color: Color(0xff44673E)),
                ),
              Text(
                scoreText(scores, li),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    int sumPressScores(Player p, int fromAbs, int toAbs, int startHole, {PressMatchModel? press}) {
      final list = pressScoresList(p);
      int total = 0;
      for (int h = fromAbs; h < toAbs; h++) {
        if (h < startHole) continue; // ignore before startHole
        if (press?.disableFromHoleIndex != null && h > press!.disableFromHoleIndex!) {
          continue; // ✅ ignore disabled holes
        }
        total += list[h];
      }
      return total;
    }

    int sumPressDots(Player p, int fromAbs, int toAbs, int startHole, {PressMatchModel? press}) {
      final list = pressDotsList(p);
      int total = 0;
      for (int h = fromAbs; h < toAbs; h++) {
        if (h < startHole) continue;
        if (press?.disableFromHoleIndex != null && h > press!.disableFromHoleIndex!) {
          continue; // ✅ ignore disabled holes
        }
        total += list[h];
      }
      return total;
    }

    void _startNextPressFromHole(int absHole, Player initiator) {
      final oldPress = scoreController.activePressMatch.value;

      if (oldPress != null) {
        oldPress.isActive = false;
        oldPress.disableFromHoleIndex = absHole;
        oldPress.pressedAtHole = absHole;
        oldPress.pressedBy = initiator; // ✅ store initiator
        scoreController.pressMatches.refresh();
        scoreController.activePressMatch.value = null;
      }

      final nextHole = absHole;
      if (nextHole >= endHole) {
        Get.back();
        return;
      }

      final newPress = PressMatchModel(
        player: player,
        holeIndex: nextHole,
        opponents: opponents,
        isActive: true,
      );

      scoreController.pressMatches.add(newPress);
      scoreController.pressMatches.refresh();
      scoreController.activePressMatch.value = newPress;

      Get.back();
      _showPressDialog(player, nextHole);
    }

    // -----------------------------------------------
    Get.generalDialog(
      barrierLabel: "Press Info",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final size = MediaQuery.of(context).size;
        final isLandscape = size.width > size.height;

        final dialogWidth = isLandscape ? size.width * 0.9 : size.width * 0.85;
        final dialogHeight = isLandscape ? size.height * 0.9 : size.height * 0.8;

        return Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: 0),
              child: Material(
                color: Colors.white,
                elevation: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xff87CD7C),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
                        ),
                        child: Text(
                          isFront9 ? "Press Match (Front + Back 9)" : "Back 9 Press Match",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Table
                      Expanded(
                        child: Obx(() {
                          count.value;
                          final rows = <DataRow>[];

                          if (startHole < 9) {
                            rows.add(
                              DataRow(
                                color: WidgetStateProperty.all(const Color(0xffE0E0E0)),
                                cells: [
                                  const DataCell(Text(
                                    "Front9",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff87CD7C),
                                    ),
                                  )),
                                  ...List.generate(opponents.length + 1, (_) => const DataCell(Text(""))),
                                ],
                              ),
                            );
                          }

                          for (int i = startHole; i < endHole; i++) {
                            final absHole = i;

                            if (absHole == 9) {
                              rows.add(
                                DataRow(
                                  color: WidgetStateProperty.all(const Color(0xffE0E0E0)),
                                  cells: [
                                    const DataCell(Text(
                                      "Back9",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff87CD7C),
                                      ),
                                    )),
                                    ...List.generate(opponents.length + 1, (_) => const DataCell(Text(""))),
                                  ],
                                ),
                              );
                            }

                            // disable condition
                            final currentMatch = scoreController.pressMatches
                                .firstWhereOrNull((m) => m.player == player && m.holeIndex == holeIndex);

                            final isDisabled = currentMatch?.disableFromHoleIndex != null &&
                                absHole > (currentMatch!.disableFromHoleIndex!);

                            final rowColor = isDisabled
                                ? Colors.grey.shade300 // greyed out
                                : (absHole - startHole).isEven ? Colors.white : const Color(0xffF5F5F5);

                            rows.add(
                              DataRow(
                                color: MaterialStateProperty.all(rowColor),
                                cells: [
                                  DataCell(Text("${absHole + 1}")),

                                  // Player column
                                  DataCell(
                                    isDisabled
                                        ? const Text("-", style: TextStyle(color: Colors.grey))
                                        : Row(
                                      children: [
                                        scoreWithDots(player, absHole),
                                        if (shouldShowPressButton(
                                          player,
                                          absHole,
                                          isPressMatch: true,
                                          pressMatch: scoreController.activePressMatch.value,
                                        ) ||
                                            wasPressedHere(player, absHole)) ...[
                                          const SizedBox(width: 10),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(40, 20),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: wasPressedHere(player, absHole)
                                                ? null
                                                : () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: const Text("Confirmation"),
                                                  content: const Text("Are you sure you want to play a press match?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Get.back(), // ❌ Cancel
                                                      child: const Text("No"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Get.back(); // dialog band
                                                        _startNextPressFromHole(absHole, player); // ✅ next press start
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Press",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: wasPressedHere(player, absHole)
                                                    ? Colors.grey // ✅ after press → grey
                                                    : Colors.green, // ✅ default → green
                                              ),
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),

                                  // Opponents
                                  ...opponents.map(
                                        (o) => DataCell(
                                      isDisabled
                                          ? const Text("-", style: TextStyle(color: Colors.grey))
                                          : Row(
                                        children: [
                                          scoreWithDots(o, absHole),
                                          if (shouldShowPressButton(
                                            o,
                                            absHole,
                                            isPressMatch: true,
                                            pressMatch: scoreController.activePressMatch.value,
                                          ) ||
                                              wasPressedHere(o, absHole)) ...[
                                            const SizedBox(width: 10),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(40, 20),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              onPressed: wasPressedHere(o, absHole)
                                                  ? null
                                                  : () {
                                                Get.dialog(
                                                  AlertDialog(
                                                    title: const Text("Confirmation"),
                                                    content: const Text("Are you sure you want to play a press match?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Get.back(), // ❌ Cancel
                                                        child: const Text("No"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Get.back();
                                                          _startNextPressFromHole(absHole, o); // ✅ next press start
                                                        },
                                                        child: const Text("Yes"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "Press",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: wasPressedHere(o, absHole)
                                                      ? Colors.grey // ✅ after press → grey
                                                      : Colors.green, // ✅ default → green
                                                ),
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          // Totals row
                          // find current press match for this player
                          final currentMatch = scoreController.pressMatches
                              .firstWhereOrNull((m) => m.player == player && m.holeIndex == holeIndex);

                          rows.add(
                            DataRow(
                              color: MaterialStateProperty.all(const Color(0xff87CD7C)),
                              cells: [
                                const DataCell(Text(
                                  "Total",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                )),
                                // ---- Player total ----
                                DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isDotEnabled.value)
                                      Text(
                                        "Dots: ${sumPressDots(player, startHole, endHole, startHole, press: currentMatch)}",
                                        style: const TextStyle(fontSize: 12, color: Color(0xff44673E)),
                                      ),
                                    Text(
                                      "${sumPressScores(player, startHole, endHole, startHole, press: currentMatch)}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                )),
                                // ---- Opponents total ----
                                ...opponents.map((o) {
                                  final oppMatch = scoreController.pressMatches
                                      .firstWhereOrNull((m) => m.player == player && m.holeIndex == holeIndex);

                                  return DataCell(Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isDotEnabled.value)
                                        Text(
                                          "Dots: ${sumPressDots(o, startHole, endHole, startHole, press: oppMatch)}",
                                          style: const TextStyle(fontSize: 12, color: Color(0xff44673E)),
                                        ),
                                      Text(
                                        "${sumPressScores(o, startHole, endHole, startHole, press: oppMatch)}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                    ],
                                  ));
                                }),
                              ],
                            ),
                          );

                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columns: [
                                const DataColumn(label: Text("Hole")),
                                DataColumn(label: Text(player.name)),
                                ...opponents.map((o) => DataColumn(label: Text(o.name))),
                              ],
                              rows: rows,
                            ),
                          );
                        }),
                      ),

                      // Close button: sirf dialog band kare
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Close"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final offsetAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim1);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  void _showScoreDialog(Player player, int hole, {bool isPress = false}) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${player.name} - Hole ${hole + 1} ${isPress ? "(Press)" : ""}'),
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
                      if (matchType == MatchType.open) {
                        if (isPress) {
                          player.pressScores[hole] = score;
                        } else {
                          player.scores[hole] = score;
                        }
                      } else {
                        if (currentTabIndex == 0) {
                          if (isPress) {
                            player.pressFront9Scores[hole] = score;
                          } else {
                            player.front9Scores[hole] = score;
                          }
                        } else if (currentTabIndex == 1) {
                          if (isPress) {
                            player.pressBack9Scores[hole] = score;
                          } else {
                            player.back9Scores[hole] = score;
                          }
                        } else {
                          if (isPress) {
                            player.pressAll18Scores[hole] = score;
                          } else {
                            player.all18Scores[hole] = score;
                          }
                        }
                      }
                      count.value++;
                      Navigator.of(context).pop();
                      if (isDotEnabled.value) {
                        _showDotsDialog(player, hole, isPress: isPress);
                      }
                    },
                    child: Text(score.toString()),
                  );
                }),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(label: Text('Custom Value')),
                onFieldSubmitted: (val) {
                  var number = int.tryParse(val) ?? 0;
                  var currentTabIndex = tabController.index;
                  if (matchType == MatchType.open) {
                    if (isPress) {
                      player.pressScores[hole] = number;
                    } else {
                      player.scores[hole] = number;
                    }
                  } else {
                    if (currentTabIndex == 0) {
                      if (isPress) {
                        player.pressFront9Scores[hole] = number;
                      } else {
                        player.front9Scores[hole] = number;
                      }
                    } else if (currentTabIndex == 1) {
                      if (isPress) {
                        player.pressBack9Scores[hole] = number;
                      } else {
                        player.back9Scores[hole] = number;
                      }
                    } else {
                      if (isPress) {
                        player.pressAll18Scores[hole] = number;
                      } else {
                        player.all18Scores[hole] = number;
                      }
                    }
                  }
                  count.value++;
                  Navigator.of(context).pop();
                  if (isDotEnabled.value) {
                    _showDotsDialog(player, hole, isPress: isPress);
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _showDotsDialog(Player player, int hole, {bool isPress = false}) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '${player.name} - Hole ${hole + 1} Dots ${isPress ? "(Press)" : ""}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Wrap(
            spacing: 10,
            children: List.generate(7, (index) {
              return ElevatedButton(
                onPressed: () {
                  var currentTabIndex = tabController.index;

                  if (matchType == MatchType.open) {
                    if (isPress) {
                      player.pressDots[hole] = index;
                    } else {
                      player.dots[hole] = index;
                    }
                  } else {
                    if (currentTabIndex == 0) {
                      if (isPress) {
                        player.pressFront9Dots[hole] = index;
                      } else {
                        player.front9Dots[hole] = index;
                      }
                    } else if (currentTabIndex == 1) {
                      if (isPress) {
                        player.pressBack9Dots[hole] = index;
                      } else {
                        player.back9Dots[hole] = index;
                      }
                    } else {
                      if (isPress) {
                        player.pressAll18Dots[hole] = index;
                      } else {
                        player.all18Dots[hole] = index;
                      }
                    }
                  }

                  /// 🔥 Refresh UI
                  count.value++;

                  Navigator.of(context).pop();
                },
                child: Text(index.toString()), // 0–6 show hoga
              );
            }),
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
        Get.toNamed(
          Routes.RESULT,
          arguments: {
            "players": players,
            "pressMatches": pressMatches, // 👈 ye bhejna hoga
          },
        );
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

  // Normal scores/dots
  List<int> scores;
  List<int> dots;
  List<int> front9Scores;
  List<int> back9Scores;
  List<int> all18Scores;
  List<int> front9Dots;
  List<int> back9Dots;
  List<int> all18Dots;

  // Press scores/dots (alag storage)
  List<int> pressScores;
  List<int> pressDots;
  List<int> pressFront9Scores;
  List<int> pressBack9Scores;
  List<int> pressAll18Scores;
  List<int> pressFront9Dots;
  List<int> pressBack9Dots;
  List<int> pressAll18Dots;

  Player({required this.name})
      : scores = List.filled(18, 0),
        dots = List.filled(18, 0),
        front9Scores = List.filled(9, 0),
        back9Scores = List.filled(9, 0),
        all18Scores = List.filled(18, 0),
        front9Dots = List.filled(9, 0),
        back9Dots = List.filled(9, 0),
        all18Dots = List.filled(18, 0),
        pressScores = List.filled(18, 0),
        pressDots = List.filled(18, 0),
        pressFront9Scores = List.filled(9, 0),
        pressBack9Scores = List.filled(9, 0),
        pressAll18Scores = List.filled(18, 0),
        pressFront9Dots = List.filled(9, 0),
        pressBack9Dots = List.filled(9, 0),
        pressAll18Dots = List.filled(18, 0);
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

class PressMatchModel {
  final Player player;
  final int holeIndex;
  final List<Player> opponents;
  bool isActive;
  Rx<Offset> buttonPosition;
  int? disableFromHoleIndex;
  int? pressedAtHole;
  Player? pressedBy;


  PressMatchModel({
    required this.player,
    required this.holeIndex,
    required this.opponents,
    this.isActive = true,
    this.disableFromHoleIndex,
    Offset? initialPosition,
    this.pressedAtHole,
  })  : buttonPosition = (initialPosition ?? const Offset(300, 200)).obs;
}



