import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:golf_score_card/app/utils/dialog_helper.dart';
import 'package:hugeicons/hugeicons.dart';

class PlayerTiler extends StatelessWidget {
  final String playerNumber;
  final RxString playerName;
  final void Function()? onDelete;

  const PlayerTiler({
    super.key,
    required this.playerNumber,
    required this.playerName,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
            color: Color(0xff87CD7C).withValues(alpha: 0.3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff87CD7C),
            ),
            child: Center(
              child: Text(
                playerNumber,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Gap(10),
          Image.asset('assets/player.png', width: 18, height: 18),
          Gap(10),
          Expanded(
            child: Obx(() => Text(
                playerName.value,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Gap(10),
          IconButton(
            onPressed: () async {
              var newName = await DialogHelper.showEditPlayerDialog(
                playerName.value,
              );
              if (newName != null && newName.isNotEmpty) {
                playerName.value = newName;
              }
            },
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedPencilEdit02,
              color: Color(0xff87CD7C),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedDelete01,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
