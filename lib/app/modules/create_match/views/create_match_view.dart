import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:golf_score_card/app/widgets/custom_button.dart';
import 'package:golf_score_card/app/widgets/custom_dropdown.dart';
import 'package:golf_score_card/app/widgets/player_tiler.dart';
import '../controllers/create_match_controller.dart';

class CreateMatchView extends GetView<CreateMatchController> {
  const CreateMatchView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text('Players', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
            Gap(10),
            Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.players.length,
                itemBuilder: (context, index) => PlayerTiler(
                  playerNumber: '${index + 1}',
                  playerName: controller.players[index],
                  onDelete: () => controller.deletePlayer(index),
                )),
            ),
            Gap(10),
            Text('Match Type', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),),
            Gap(10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Color(0xff87cd7c).withValues(alpha: 0.3)
                  )
                ]
              ),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        controller.matchType.value = MatchType.open;
                      },
                      child: Container(
                        height: 41,
                        decoration: BoxDecoration(
                          color: controller.matchType.value == MatchType.open ? Color(0xff87CD7C) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Open',
                            style: TextStyle(
                                color: controller.matchType.value == MatchType.open ? Colors.white : Colors.black
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        controller.matchType.value = MatchType.nassau;
                      },
                      child: Container(
                        height: 41,
                        decoration: BoxDecoration(
                          color: controller.matchType.value == MatchType.nassau ? Color(0xff87CD7C) : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            'Nassau',
                            style: TextStyle(
                                color: controller.matchType.value == MatchType.nassau ? Colors.white : Colors.black
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              ),
            ),
            Gap(20),
            CustomDropdown(items: controller.matches, onChanged: (val){
              controller.match1 = val;
            },),
            Gap(5),
            CustomDropdown(items: controller.matches, onChanged: (val){
              controller.match2 = val;
            },),
            Gap(5),
            CustomDropdown(items: controller.matches, onChanged: (val){
              controller.match3 = val;
            },),
            Gap(10),
            CustomButton(
                onTap: () => controller.goToScorecard(),
                width: 129,
                height: 43,
                text: 'Play'),
            Gap(20)
          ],
        ),
      )
    );
  }
}
