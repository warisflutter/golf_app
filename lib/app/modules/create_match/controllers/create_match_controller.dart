import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../routes/app_pages.dart';
import '../../scorecard/controllers/scorecard_controller.dart';

enum MatchType{
  open,
  nassau
}

class CreateMatchController extends GetxController {
  //TODO: Implement CreateMatchController

  var matchType = MatchType.open.obs;
  RxList<RxString> players = <RxString>[].obs;
  List<PlayerMatch> matches = [];
  List<PlayerMatch> selectedPlayerMatches = [];
  PlayerMatch? match1;
  PlayerMatch? match2;
  PlayerMatch? match3;
  @override
  void onInit() {
    players.add('Eric'.obs);
    players.add('Carter'.obs);
    players.add('Jeff'.obs);
    players.add('Danny'.obs);
    matches = generatePlayerPairs();
    super.onInit();

  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void deletePlayer(int index){
    players.removeAt(index);
  }

  List<PlayerMatch> generatePlayerPairs() {
    List<PlayerMatch> matches = [];
    final uuid = Uuid();
    for (int i = 0; i < players.length; i++) {
      for (int j = i + 1; j < players.length; j++) {
        matches.add(PlayerMatch(id: uuid.v4(), player1: Player(name: players[i].value), player2:Player(name: players[j].value)));
      }
    }
    return matches;
  }

  void goToScorecard(){
    selectedPlayerMatches.clear();
    if(match1 != null){
      selectedPlayerMatches.add(match1!);
    }
    if(match2 != null){
      var isMatchExists = selectedPlayerMatches.any((e) => e.id == match2!.id);
      if(isMatchExists){
        Get.showSnackbar(GetSnackBar(
          title: 'Duplicate Matches',
          message: '${match2?.player1.name} vs. ${match2?.player2.name} set multiple times.',
          backgroundColor: Colors.amber,
        ));
        return;
      }
      selectedPlayerMatches.add(match2!);
    }
    if(match3 != null){
      var isMatchExists = selectedPlayerMatches.any((e) => e.id == match3!.id);
      if(isMatchExists){
        Get.showSnackbar(GetSnackBar(
          title: 'Duplicate Matches',
          message: '${match3?.player1.name} vs. ${match3?.player2.name} set multiple times.',
          backgroundColor: Colors.amber,
        ));
        return;
      }
      selectedPlayerMatches.add(match3!);
    }
    MatchPreference pref = selectedPlayerMatches.isEmpty ? MatchPreference.single : MatchPreference.match;
    List<Player> selectedPlayers = [];
    if(selectedPlayerMatches.isNotEmpty){
      for(var item in selectedPlayerMatches){
        var isPlayer1Exists = selectedPlayers.any((p) => p.name == item.player1.name);
        if(!isPlayer1Exists){
          selectedPlayers.add(Player(name: item.player1.name));
        }
        var isPlayer2Exists = selectedPlayers.any((p) => p.name == item.player2.name);
        if(!isPlayer2Exists){
          selectedPlayers.add(Player(name: item.player2.name));
        }
      }
    }
    else{
      selectedPlayers = players.map((e) => Player(name: e.value)).toList();
    }
    MatchInfo info = MatchInfo(players: selectedPlayers, preference: pref, matches: selectedPlayerMatches);
    Get.toNamed(Routes.SCORECARD, arguments: {'type': matchType.value, 'info': info, 'pref': pref});
  }

}
