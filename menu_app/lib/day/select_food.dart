import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/add_dish.dart';
import 'package:menu_app/gsheets_api.dart';

class SimpleFoodDialog extends StatefulWidget {
  const SimpleFoodDialog({super.key});

  @override
  State<SimpleFoodDialog> createState() => _SimpleFoodDialogState();
}

Widget simpleFoodDialog(BuildContext context, String panelDate, int columnNumberToAddFood, List<String> prefix) {
  return const SimpleFoodDialog();
}

class _SimpleFoodDialogState extends State<SimpleFoodDialog> {
  final TextEditingController searchController = TextEditingController();

  int selectedTabIndex = 0;

  static const List<String> tabIcons = [
    "assets/icons/everything.svg",
    "assets/icons/carb.svg",
    "assets/icons/nonveg.svg",
    "assets/icons/veg.svg",
    "assets/icons/fruit.svg",
    "assets/icons/dessert.svg",
    "assets/icons/drink.svg",
  ];

  static const List<String> tabLabels = [
    "All Foods",
    "Carbs",
    "Non-Veg",
    "Veg",
    "Fruits",
    "Desserts",
    "Drinks",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 400,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // search menu and main panel
            Expanded(flex: 4, child: searchPanel()),

            const SizedBox(width: 12),

            // right panel for icons 
            Column(
              children: [
                Expanded(child: iconTabsPanel()),
                const SizedBox(height: 12),
                SizedBox(width: 50, height: 50, child: addButtonPanel()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectFoodBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Text(
            tabLabels[selectedTabIndex],
            style: TextStyle(
              color: whiteText, 
              fontSize: tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 42,
            child: TextField(
              cursorHeight: 20,
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search..',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: tertiaryText),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        
          const SizedBox(height: 10),

          Expanded(child: foodListView()),
        ],
      ),
    );
  }

  Widget foodListView() {
    final items = List<List<String>>.from(GoogleSheetsApi.foodItems)
    ..sort((a, b) {
      final nameA = a.length > 1 ? a[1] : a.first;
      final nameB = b.length > 1 ? b[1] : b.first;
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final row = items[i];
          final displayName = row.length > 1 ? row[1] : row.first;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  // Navigator.of(context).pop(food);
                  // final target = GoogleSheetsApi.findRowIndexByDate(widget.panelDate);
                  // if (target != -1) await GoogleSheetsApi.updateSingleMealSlot(rowIndex: target, columnIndex: widget.columnNumberToAddFood, foodId: food.id);
                },
                splashColor: Colors.white12,
                highlightColor: Colors.white10,

                child: Slidable(
                  startActionPane: ActionPane(motion: const StretchMotion(), children: [
                    SlidableAction(onPressed: (_) { HapticFeedback.lightImpact(); }, icon: Icons.info_outline, backgroundColor: fadedGrey),
                  ]),
                  endActionPane: ActionPane(motion: const StretchMotion(), children: [
                    SlidableAction(onPressed: (_) { HapticFeedback.lightImpact(); }, icon: Icons.delete, backgroundColor: expRed),
                  ]),
                  
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    color: selectFoodListBg,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                  
                        // food type circle
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: white,
                          ),
                        ),
                  
                        const SizedBox(width: 12),
                  
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(color: whiteText, fontSize: tertiaryText),
                              ),
                              Text(
                                "Made 5 days ago",
                                style: TextStyle(color: whiteText.withValues(alpha: 0.5), fontSize: quaternaryText),
                              ),
                            ],
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
      ),
    );
  }

  // right panel
  Widget iconTabsPanel() {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: selectFoodBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(tabIcons.length, (i) => tabIcon(i)),
      ),
    );
  }

  // right panel icons
  Widget tabIcon(int index) {
    final bool isSelected = selectedTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => selectedTabIndex = index),
      child: SizedBox(
        width: 50,
        height: 40,
        child: Center(
          child: SvgPicture.asset(
            tabIcons[index],
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white70 : Colors.white24,
              BlendMode.srcIn,
            ),
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }

  // add button on the right bottom
  Widget addButtonPanel() {
    return Container(
      decoration: BoxDecoration(
        color: selectFoodBg,
        borderRadius: BorderRadius.circular(200),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            await showAddDishDialog(context);
            setState(() {});
          },
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.add, color: Colors.white60),
          ),
        ),
      ),
    );
  }
}