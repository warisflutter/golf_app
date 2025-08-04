import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:golf_score_card/app/widgets/custom_button.dart';
import 'package:lottie/lottie.dart';

class DialogHelper{
  static Future<String?> showEditPlayerDialog(String playerName) async{
    final TextEditingController controller = TextEditingController()..text = playerName;
    var result = await Get.dialog<String>(Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Player', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600
            ),),
            Lottie.asset('assets/anim_edit.json', width: 128, height: 128),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                label: Text('Player Name')
              ),
            ),
            Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 33,
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: ''),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xff87CD7C), width: 1), // Green border
                      ),
                      backgroundColor: Colors.transparent, // Optional: change background if needed
                      foregroundColor: Color(0xff44673E), // Optional: green text color
                      elevation: 0, // Optional: remove shadow
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                Gap(10),
                CustomButton(onTap: (){
                  Get.back(result: controller.text);
                }, width: 80, height: 33, text: 'Confirm'),
              ],
            )
          ],
        ),
      ),
    ));
    return result;
  }
}