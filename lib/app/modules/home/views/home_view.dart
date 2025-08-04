import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/custom_button.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    bool isLandscaped = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golf Scorecard'),
        centerTitle: true,
      ),
      body:
      controller.matches.isEmpty ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/anim_playing.json', width: isLandscaped ?  Get.width / 3 : 250, height: isLandscaped ? Get.height / 3 : 250),
              Text('No Active Matches', style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
                textAlign: TextAlign.center,),
              Gap(10),
              Text('Start a new match to track your score and compete with friends', textAlign: TextAlign.center,),
              Gap(20),
              CustomButton(onTap: () => Get.toNamed(Routes.CREATE_MATCH), width: 244, height: 54, text: 'Create New Match'),
            ],
          ),
        ),
      ) : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          ],
        ),
      )
    );
  }
}



// Data Models
class Player {
  String name;
  List<int> scores;
  List<int> dots;

  Player({required this.name}) : scores = List.filled(18, 0), dots = List.filled(18, 0);
}

class Match {
  String id;
  List<Player> players;
  Player player1;
  Player player2;
  int currentHole;
  bool isPress;
  int startHole;
  String? originalMatchId;

  Match({
    required this.id,
    required this.players,
    required this.player1,
    required this.player2,
    this.currentHole = 1,
    this.isPress = false,
    this.startHole = 1,
    this.originalMatchId,
  });
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.golf_course,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 30),
            const Text(
              'Golf Match Tracker',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Create New Match',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to match history
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Match History',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
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
  List<Player> selectedPlayers = [];
  Player? player1;
  Player? player2;
  bool dotsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add default players
    for (String name in defaultPlayers) {
      selectedPlayers.add(Player(name: name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Players',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: selectedPlayers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(selectedPlayers[index].name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedPlayers.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddPlayerDialog();
                    },
                    child: const Text('Add Player'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text('Enable Dots'),
              value: dotsEnabled,
              onChanged: (bool? value) {
                setState(() {
                  dotsEnabled = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Match Players',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<Player>(
                    hint: const Text('Player 1'),
                    value: player1,
                    isExpanded: true,
                    items: selectedPlayers.map((Player player) {
                      return DropdownMenuItem<Player>(
                        value: player,
                        child: Text(player.name),
                      );
                    }).toList(),
                    onChanged: (Player? value) {
                      setState(() {
                        player1 = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                const Text('VS'),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<Player>(
                    hint: const Text('Player 2'),
                    value: player2,
                    isExpanded: true,
                    items: selectedPlayers.where((p) => p != player1).map((Player player) {
                      return DropdownMenuItem<Player>(
                        value: player,
                        child: Text(player.name),
                      );
                    }).toList(),
                    onChanged: (Player? value) {
                      setState(() {
                        player2 = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (player1 != null && player2 != null && selectedPlayers.length >= 2)
                    ? () {
                  Match newMatch = Match(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    players: selectedPlayers,
                    player1: player1!,
                    player2: player2!,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScorecardScreen(
                        match: newMatch,
                        dotsEnabled: dotsEnabled,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Start Match',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlayerDialog() {
    String newPlayerName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Player'),
          content: TextField(
            onChanged: (value) {
              newPlayerName = value;
            },
            decoration: const InputDecoration(hintText: 'Enter player name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newPlayerName.isNotEmpty) {
                  setState(() {
                    selectedPlayers.add(Player(name: newPlayerName));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Scorecard Screen
class ScorecardScreen extends StatefulWidget {
  final Match match;
  final bool dotsEnabled;

  const ScorecardScreen({
    super.key,
    required this.match,
    required this.dotsEnabled,
  });

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  String viewMode = 'All 18'; // 'Front 9', 'Back 9', 'All 18'
  List<Match> pressMatches = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scorecard'),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                viewMode = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'Front 9', child: Text('Front 9')),
              const PopupMenuItem(value: 'Back 9', child: Text('Back 9')),
              const PopupMenuItem(value: 'All 18', child: Text('All 18')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // View Mode Indicator
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              viewMode,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Scorecard Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _buildColumns(),
                rows: _buildRows(),
              ),
            ),
          ),
          // Match Status and Press Options
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildMatchStatus(),
                const SizedBox(height: 10),
                _buildPressButton(),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            match: widget.match,
                            pressMatches: pressMatches,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('View Results', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [const DataColumn(label: Text('Hole'))];

    for (Player player in widget.match.players) {
      columns.add(DataColumn(label: Text(player.name)));
    }

    return columns;
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    int startHole = viewMode == 'Back 9' ? 9 : 0;
    int endHole = viewMode == 'Front 9' ? 9 : (viewMode == 'Back 9' ? 18 : 18);

    for (int hole = startHole; hole < endHole; hole++) {
      List<DataCell> cells = [DataCell(Text('${hole + 1}'))];

      for (Player player in widget.match.players) {
        cells.add(DataCell(
          GestureDetector(
            onTap: () => _showScoreDialog(player, hole),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.dotsEnabled && player.dots[hole] > 0)
                  Text(
                    '•' * player.dots[hole],
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                Text(
                  player.scores[hole] == 0 ? '-' : player.scores[hole].toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ));
      }

      rows.add(DataRow(cells: cells));
    }

    // Total row
    List<DataCell> totalCells = [const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold)))];
    for (Player player in widget.match.players) {
      int total = 0;
      int totalDots = 0;
      int start = viewMode == 'Back 9' ? 9 : 0;
      int end = viewMode == 'Front 9' ? 9 : 18;

      for (int i = start; i < end; i++) {
        total += player.scores[i];
        totalDots += player.dots[i];
      }

      totalCells.add(DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.dotsEnabled && totalDots > 0)
              Text(
                'Dots: $totalDots',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            Text(
              total.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));
    }
    rows.add(DataRow(cells: totalCells));

    return rows;
  }

  void _showScoreDialog(Player player, int hole) {
    showDialog(
      context: context,
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
                children: List.generate(10, (index) {
                  int score = index + 1;
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        player.scores[hole] = score;
                      });
                      Navigator.of(context).pop();

                      if (widget.dotsEnabled) {
                        _showDotsDialog(player, hole);
                      }
                    },
                    child: Text(score.toString()),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDotsDialog(Player player, int hole) {
    showDialog(
      context: context,
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
                      setState(() {
                        player.dots[hole] = index;
                      });
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

  Widget _buildMatchStatus() {
    int player1Wins = 0;
    int player2Wins = 0;

    for (int hole = 0; hole < 18; hole++) {
      if (widget.match.player1.scores[hole] > 0 && widget.match.player2.scores[hole] > 0) {
        if (widget.match.player1.scores[hole] < widget.match.player2.scores[hole]) {
          player1Wins++;
        } else if (widget.match.player2.scores[hole] < widget.match.player1.scores[hole]) {
          player2Wins++;
        }
      }
    }

    String status;
    if (player1Wins > player2Wins) {
      status = '${widget.match.player1.name} Up ${player1Wins - player2Wins}';
    } else if (player2Wins > player1Wins) {
      status = '${widget.match.player2.name} Up ${player2Wins - player1Wins}';
    } else {
      status = 'Even';
    }

    return Text(
      'Match Status: $status',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPressButton() {
    int player1Wins = 0;
    int player2Wins = 0;

    for (int hole = 0; hole < 18; hole++) {
      if (widget.match.player1.scores[hole] > 0 && widget.match.player2.scores[hole] > 0) {
        if (widget.match.player1.scores[hole] < widget.match.player2.scores[hole]) {
          player1Wins++;
        } else if (widget.match.player2.scores[hole] < widget.match.player1.scores[hole]) {
          player2Wins++;
        }
      }
    }

    bool player1Losing = player1Wins < player2Wins;
    bool player2Losing = player2Wins < player1Wins;

    if (!player1Losing && !player2Losing) {
      return const SizedBox.shrink();
    }

    String losingPlayer = player1Losing ? widget.match.player1.name : widget.match.player2.name;

    return ElevatedButton(
      onPressed: () => _startPress(),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      child: Text('$losingPlayer - Start Press', style: const TextStyle(color: Colors.white)),
    );
  }

  void _startPress() {
    int currentHole = 1;
    for (int i = 0; i < 18; i++) {
      if (widget.match.player1.scores[i] == 0 || widget.match.player2.scores[i] == 0) {
        currentHole = i + 1;
        break;
      }
    }

    Match pressMatch = Match(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      players: widget.match.players,
      player1: widget.match.player1,
      player2: widget.match.player2,
      isPress: true,
      startHole: currentHole,
      originalMatchId: widget.match.id,
    );

    setState(() {
      pressMatches.add(pressMatch);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Press match started from hole $currentHole')),
    );
  }
}

// Result Screen
class ResultScreen extends StatelessWidget {
  final Match match;
  final List<Match> pressMatches;

  const ResultScreen({
    super.key,
    required this.match,
    required this.pressMatches,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Results'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Results',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMainMatchResults(),
            const SizedBox(height: 30),
            if (pressMatches.isNotEmpty) ...[
              const Text(
                'Press Match Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...pressMatches.map((press) => _buildPressResults(press)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('New Match', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMatchResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match.player1.name} vs ${match.player2.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildNassauResults(),
            const SizedBox(height: 10),
            _buildMatchPlayResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildNassauResults() {
    // Front 9
    int front9Player1 = match.player1.scores.sublist(0, 9).reduce((a, b) => a + b);
    int front9Player2 = match.player2.scores.sublist(0, 9).reduce((a, b) => a + b);

    // Back 9
    int back9Player1 = match.player1.scores.sublist(9, 18).reduce((a, b) => a + b);
    int back9Player2 = match.player2.scores.sublist(9, 18).reduce((a, b) => a + b);

    // Overall
    int totalPlayer1 = match.player1.scores.reduce((a, b) => a + b);
    int totalPlayer2 = match.player2.scores.reduce((a, b) => a + b);

    return Column(
      children: [
        const Text('Nassau Results:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Front 9: ${match.player1.name} $front9Player1 - ${match.player2.name} $front9Player2'),
        Text('Back 9: ${match.player1.name} $back9Player1 - ${match.player2.name} $back9Player2'),
        Text('Overall: ${match.player1.name} $totalPlayer1 - ${match.player2.name} $totalPlayer2'),
      ],
    );
  }

  Widget _buildMatchPlayResult() {
    int player1Wins = 0;
    int player2Wins = 0;

    for (int hole = 0; hole < 18; hole++) {
      if (match.player1.scores[hole] < match.player2.scores[hole]) {
        player1Wins++;
      } else if (match.player2.scores[hole] < match.player1.scores[hole]) {
        player2Wins++;
      }
    }

    String result;
    if (player1Wins > player2Wins) {
      result = '${match.player1.name} wins ${player1Wins - player2Wins} up';
    } else if (player2Wins > player1Wins) {
      result = '${match.player2.name} wins ${player2Wins - player1Wins} up';
    } else {
      result = 'Match halved';
    }

    return Text('Match Play: $result', style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildPressResults(Match pressMatch) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('Press from hole ${pressMatch.startHole}: [Press results would be calculated here]'),
      ),
    );
  }
}