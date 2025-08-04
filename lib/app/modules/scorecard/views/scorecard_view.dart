import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scorecard_controller.dart';

class ScorecardView extends GetView<ScorecardController> {
  const ScorecardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          controller.tabController = DefaultTabController.of(context);
          controller.tabController.addListener(() {
            if (!controller.tabController.indexIsChanging) {
              controller.currentTabIndex.value = controller.tabController.index;
            }
          });
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text(
                'Scorecard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Color(0xffF2F2F2),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    labelColor: Color(0xff87CD7C),
                    tabs: [
                      Tab(text: 'Front 9'),
                      Tab(text: 'Back 9'),
                      Tab(text: 'All 18'),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    const Text('Enable Dots', style: TextStyle(fontSize: 14)),
                    Obx(
                          () => Checkbox.adaptive(
                        visualDensity: VisualDensity.compact,
                        value: controller.isDotEnabled.value,
                        side: BorderSide(color: Colors.grey, width: 1.5),
                        activeColor: Color(0xff87CD7C),
                        onChanged: (val) {
                          controller.isDotEnabled.value = val!;
                        },
                      ),
                    ),
                  ],
                ),
                PopupMenuButton(
                  color: Colors.white,
                  itemBuilder:
                      (_) => [
                        PopupMenuItem(
                          value: 0,
                          child: Text('1-6', style: TextStyle(color: Color(0xff44673E)),),
                          onTap: () => controller.showPlayersToHighlight(0, isLandscape),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Text('7-12', style: TextStyle(color: Color(0xff44673E)),),
                          onTap: () => controller.showPlayersToHighlight(1, isLandscape),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text('13-18', style: TextStyle(color: Color(0xff44673E)),),
                          onTap: () => controller.showPlayersToHighlight(2, isLandscape),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Text('View Results', style: TextStyle(color: Color(0xff44673E)),),
                          onTap: () => controller.showPlayersToHighlight(3, isLandscape),
                        ),
                      ],
                ),

              ],
            ),
            body: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: Get.size.width),
                    child: DataTable(
                      columnSpacing: 15,
                      key: Key('Key ${controller.currentTabIndex.value}${controller.count.value}'),
                      columns: controller.buildColumns(isLandscape: isLandscape),
                      rows: controller.buildRows(isLandscape: isLandscape),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

