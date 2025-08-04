import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Golf Scorecard",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green
        )
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
    //   MaterialApp(
    //     title: 'Golf Match App',
    //     theme: ThemeData(
    //       primarySwatch: Colors.green,
    //       useMaterial3: true,
    //     ),
    //     home: const HomeScreen(),
    //   )
  );
}





// Models
class Player {
  String name;
  List<int> scores;
  List<int> dots;

  Player({required this.name})
      : scores = List.filled(18, 0),
        dots = List.filled(18, 0);

  int get totalScore => scores.fold(0, (sum, score) => sum + score);
  int get totalDots => dots.fold(0, (sum, dot) => sum + dot);
  int get front9Score => scores.sublist(0, 9).fold(0, (sum, score) => sum + score);
  int get back9Score => scores.sublist(9, 18).fold(0, (sum, score) => sum + score);
  int get front9Dots => dots.sublist(0, 9).fold(0, (sum, dot) => sum + dot);
  int get back9Dots => dots.sublist(9, 18).fold(0, (sum, dot) => sum + dot);
}

class Match {
  String id;
  String player1;
  String player2;
  bool isPressMatch;
  int startHole;
  String? winner;
  String status; // "Up 1", "Down 2", "Even", etc.

  Match({
    required this.id,
    required this.player1,
    required this.player2,
    this.isPressMatch = false,
    this.startHole = 0,
    this.winner,
    this.status = "Even",
  });
}

class GameSession {
  List<Player> players;
  String matchType; // "Open" or "Nassau"
  List<Match> matches;
  bool dotsEnabled;
  String courseSelection;

  GameSession({
    required this.players,
    required this.matchType,
    this.matches = const [],
    this.dotsEnabled = true,
    this.courseSelection = "Manual Entry",
  });
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golf Match App'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.golf_course, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Golf Match Tracker',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Match'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MatchHistoryScreen()),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Match History'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create Match Screen
class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final List<String> defaultPlayers = ['Eric', 'Carter', 'Jeff', 'Danny'];
  List<String> selectedPlayers = [];
  String selectedMatchType = 'Open';
  bool dotsEnabled = true;
  String courseSelection = 'Manual Entry';
  List<Match> selectedMatches = [];

  @override
  void initState() {
    super.initState();
    selectedPlayers = List.from(defaultPlayers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Type Selection
            const Text('Match Type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedMatchType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ['Open', 'Nassau'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMatchType = value!;
                  selectedMatches.clear();
                });
              },
            ),
            const SizedBox(height: 20),

            // Players Selection
            const Text('Players:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...selectedPlayers.map((player) => CheckboxListTile(
              title: Text(player),
              value: true,
              onChanged: null, // Keep all players selected for now
            )),
            const SizedBox(height: 20),

            // Match Setup (only for Nassau)
            if (selectedMatchType == 'Nassau') ...[
              const Text('Select Matches:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _showMatchSelectionDialog(),
                child: Text('Add Match (${selectedMatches.length} selected)'),
              ),
              const SizedBox(height: 8),
              ...selectedMatches.map((match) => Card(
                child: ListTile(
                  title: Text('${match.player1} vs ${match.player2}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        selectedMatches.remove(match);
                      });
                    },
                  ),
                ),
              )),
              const SizedBox(height: 20),
            ],

            // Course Selection
            const Text('Course:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: courseSelection,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ['Manual Entry', 'Pebble Beach', 'Augusta National', 'St. Andrews']
                  .map((course) => DropdownMenuItem(value: course, child: Text(course)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  courseSelection = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Dots Toggle
            SwitchListTile(
              title: const Text('Enable Dots'),
              value: dotsEnabled,
              onChanged: (value) {
                setState(() {
                  dotsEnabled = value;
                });
              },
            ),
            const Spacer(),

            // Start Match Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canStartMatch() ? _startMatch : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start Match', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canStartMatch() {
    if (selectedMatchType == 'Nassau') {
      return selectedMatches.isNotEmpty;
    }
    return selectedPlayers.length >= 2;
  }

  void _showMatchSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Match'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _generateMatchCombinations()
                .map((combination) => RadioListTile<String>(
              title: Text(combination),
              value: combination,
              groupValue: null,
              onChanged: (value) {
                final players = value!.split(' vs ');
                final match = Match(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  player1: players[0],
                  player2: players[1],
                );
                setState(() {
                  selectedMatches.add(match);
                });
                Navigator.pop(context);
              },
            ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<String> _generateMatchCombinations() {
    List<String> combinations = [];
    for (int i = 0; i < selectedPlayers.length; i++) {
      for (int j = i + 1; j < selectedPlayers.length; j++) {
        combinations.add('${selectedPlayers[i]} vs ${selectedPlayers[j]}');
      }
    }
    return combinations;
  }

  void _startMatch() {
    final gameSession = GameSession(
      players: selectedPlayers.map((name) => Player(name: name)).toList(),
      matchType: selectedMatchType,
      matches: selectedMatches,
      dotsEnabled: dotsEnabled,
      courseSelection: courseSelection,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScorecardScreen(gameSession: gameSession),
      ),
    );
  }
}

// Scorecard Screen
class ScorecardScreen extends StatefulWidget {
  final GameSession gameSession;

  const ScorecardScreen({super.key, required this.gameSession});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> with TickerProviderStateMixin {
  late TabController tabController;
  ValueNotifier<bool> isDotEnabled = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    isDotEnabled.value = widget.gameSession.dotsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gameSession.matchType} Match'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Front 9'),
            Tab(text: 'Back 9'),
            Tab(text: 'Results'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildScorecardView(0), // Front 9
          _buildScorecardView(1), // Back 9
          _buildResultsView(),     // Results
        ],
      ),
    );
  }

  Widget _buildScorecardView(int tabIndex) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return SingleChildScrollView(
          scrollDirection: isLandscape ? Axis.vertical : Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: isLandscape ? Axis.horizontal : Axis.vertical,
            child: DataTable(
              columns: _buildColumns(isLandscape: isLandscape, tabIndex: tabIndex),
              rows: _buildRows(isLandscape: isLandscape, tabIndex: tabIndex),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns({required bool isLandscape, required int tabIndex}) {
    if (isLandscape) {
      int startHole = tabIndex == 1 ? 9 : 0;
      int endHole = tabIndex == 0 ? 9 : 18;
      List<DataColumn> columns = [const DataColumn(label: Text('Player'))];
      for (int hole = startHole; hole < endHole; hole++) {
        columns.add(DataColumn(label: Text('H${hole + 1}')));
      }
      columns.add(const DataColumn(label: Text('Total')));
      if (isDotEnabled.value) {
        columns.add(const DataColumn(label: Text('Dots')));
      }
      return columns;
    } else {
      List<DataColumn> columns = [const DataColumn(label: SizedBox(width: 30, child: Text('Hole')))];
      for (var player in widget.gameSession.players) {
        columns.add(DataColumn(label: Text(player.name)));
      }
      return columns;
    }
  }

  List<DataRow> _buildRows({required bool isLandscape, required int tabIndex}) {
    if (isLandscape) {
      return widget.gameSession.players.map((player) {
        int startHole = tabIndex == 1 ? 9 : 0;
        int endHole = tabIndex == 0 ? 9 : 18;

        List<DataCell> cells = [DataCell(Text(player.name))];
        int total = 0;
        int totalDots = 0;

        for (int hole = startHole; hole < endHole; hole++) {
          final score = player.scores[hole];
          final dot = player.dots[hole];
          total += score;
          totalDots += dot;

          cells.add(DataCell(
            InkWell(
              onTap: () => _showScoreDialog(player, hole),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDotEnabled.value && player.dots[hole] > 0)
                      Text('●' * player.dots[hole],
                          style: const TextStyle(fontSize: 10, color: Colors.blue)),
                    Text(score == 0 ? '-' : score.toString(),
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ));
        }

        cells.add(DataCell(Text(total.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold))));
        if (isDotEnabled.value) {
          cells.add(DataCell(Text(totalDots.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold))));
        }
        return DataRow(cells: cells);
      }).toList();
    } else {
      int startHole = tabIndex == 1 ? 9 : 0;
      int endHole = tabIndex == 0 ? 9 : 18;

      List<DataRow> rows = [];
      for (int hole = startHole; hole < endHole; hole++) {
        List<DataCell> cells = [DataCell(Text('${hole + 1}'))];
        for (var player in widget.gameSession.players) {
          final score = player.scores[hole];
          final dot = player.dots[hole];
          cells.add(DataCell(
            InkWell(
              onTap: () => _showScoreDialog(player, hole),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDotEnabled.value && dot > 0)
                      Text('●' * dot, style: const TextStyle(fontSize: 10, color: Colors.blue)),
                    Text(score == 0 ? '-' : score.toString()),
                  ],
                ),
              ),
            ),
          ));
        }
        rows.add(DataRow(cells: cells));
      }
      return rows;
    }
  }

  Widget _buildResultsView() {
    if (widget.gameSession.matchType == 'Open') {
      return _buildOpenResults();
    } else {
      return _buildNassauResults();
    }
  }

  Widget _buildOpenResults() {
    final sortedPlayers = List<Player>.from(widget.gameSession.players)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Final Results', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0 ? Colors.deepOrange : Colors.grey,
                  child: Text('${index + 1}'),
                ),
                title: Text(player.name),
                subtitle: Text('Total Score: ${player.totalScore}'),
                trailing: isDotEnabled.value
                    ? Text('Dots: ${player.totalDots}')
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNassauResults() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nassau Results', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...widget.gameSession.matches.map((match) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${match.player1} vs ${match.player2}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildMatchResults(match),
                  if (_canPress(match)) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showPressDialog(match),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Press'),
                    ),
                  ],
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMatchResults(Match match) {
    final player1 = widget.gameSession.players.firstWhere((p) => p.name == match.player1);
    final player2 = widget.gameSession.players.firstWhere((p) => p.name == match.player2);

    final front9Result = _calculateMatchResult(player1, player2, 0, 9);
    final back9Result = _calculateMatchResult(player1, player2, 9, 18);
    final overallResult = _calculateMatchResult(player1, player2, 0, 18);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Front 9:'),
            Text(front9Result),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Back 9:'),
            Text(back9Result),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Overall:'),
            Text(overallResult),
          ],
        ),
      ],
    );
  }

  String _calculateMatchResult(Player player1, Player player2, int startHole, int endHole) {
    int player1Total = 0;
    int player2Total = 0;

    for (int i = startHole; i < endHole; i++) {
      player1Total += player1.scores[i];
      player2Total += player2.scores[i];
    }

    if (player1Total < player2Total) {
      return '${player1.name} wins';
    } else if (player2Total < player1Total) {
      return '${player2.name} wins';
    } else {
      return 'Tie';
    }
  }

  bool _canPress(Match match) {
    // Simple press logic - can press if losing by 2+ strokes in any segment
    final player1 = widget.gameSession.players.firstWhere((p) => p.name == match.player1);
    final player2 = widget.gameSession.players.firstWhere((p) => p.name == match.player2);

    // Check if either player is losing significantly
    return (player1.totalScore - player2.totalScore).abs() >= 2;
  }

  void _showPressDialog(Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Press'),
        content: Text('Start a new press match for ${match.player1} vs ${match.player2}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _createPress(match);
              Navigator.pop(context);
            },
            child: const Text('Press'),
          ),
        ],
      ),
    );
  }

  void _createPress(Match match) {
    final pressMatch = Match(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      player1: match.player1,
      player2: match.player2,
      isPressMatch: true,
      startHole: tabController.index == 0 ? 0 : 9,
    );

    setState(() {
      widget.gameSession.matches.add(pressMatch);
    });
  }

  void _showScoreDialog(Player player, int hole) {
    int currentScore = player.scores[hole];
    int currentDots = player.dots[hole];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${player.name} - Hole ${hole + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Score:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(10, (index) {
                final score = index + 1;
                return ChoiceChip(
                  label: Text('$score'),
                  selected: currentScore == score,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        currentScore = score;
                      });
                    }
                  },
                );
              }),
            ),
            if (isDotEnabled.value) ...[
              const SizedBox(height: 16),
              const Text('Dots:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  return ChoiceChip(
                    label: Text('$index'),
                    selected: currentDots == index,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          currentDots = index;
                        });
                      }
                    },
                  );
                }),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                player.scores[hole] = currentScore;
                if (isDotEnabled.value) {
                  player.dots[hole] = currentDots;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Dots'),
              value: isDotEnabled.value,
              onChanged: (value) {
                setState(() {
                  isDotEnabled.value = value;
                  widget.gameSession.dotsEnabled = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Match History Screen
class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Match history will be displayed here.\nThis feature will store and show previous matches.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}