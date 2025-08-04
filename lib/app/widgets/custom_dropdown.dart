import 'package:flutter/material.dart';
import 'package:golf_score_card/app/modules/scorecard/controllers/scorecard_controller.dart';

class CustomDropdown extends StatelessWidget {
  final List<PlayerMatch> items;
  final void Function(PlayerMatch?) onChanged;
  const CustomDropdown({super.key, required this.items, required this.onChanged});

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
      child: DropdownButtonFormField<PlayerMatch>(
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Match'
          ),
          items: items.map((e) => DropdownMenuItem<PlayerMatch>(value: e, child: Text('${e.player1.name} vs. ${e.player2.name}'))).toList(),
          onChanged: onChanged),
    );
  }
}
