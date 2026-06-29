import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/gsheets_api.dart';

Widget carbList(BuildContext context, String panelDate) {
  final List<FoodOption> carbOptions = GoogleSheetsApi.getFoodOptionsByPrefix(["c"]);
  
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.zero,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 450, 
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2b2b2b),
            border: Border.all(color: accent), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
      
              // Title
              const Text(
                "Select Carb",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      
              const SizedBox(height: 20),
      
              // 2. 💎 THE LIVE DATA LIST SECTION
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: carbOptions.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("No carbs found", style: TextStyle(color: Colors.white70)),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(), // 💎 Smooth, adaptive iOS/Android bounce scrolling
                          child: Column(
                            children: carbOptions.map((food) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop(food); // Close dialog and get selected food option

                                    // 1. Instantly pinpoint the row index for THIS specific panel's calendar date
                                    int targetRowIndex = GoogleSheetsApi.findRowIndexByDate(panelDate);

                                    if (targetRowIndex != -1) {
                                      // 2. Overwrite the exact cell directly without complex string manipulations!
                                      await GoogleSheetsApi.updateSingleMealSlot(
                                        rowIndex: targetRowIndex,
                                        columnIndex: 3, // e.g., 3 for Breakfast-Carb, 6 for Lunch-Carb
                                        foodId: food.id,
                                      );
                                    } else {
                                      print("Could not find a row match for date: $panelDate");
                                    }
                                  },
                                  splashColor: Colors.white12,
                                  highlightColor: Colors.white10,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              food.name,
                                              style: const TextStyle(color: Colors.white, fontSize: 15),
                                            ),
                                            Text(
                                              // Compute last-eaten when rendering the list for this dialog
                                              () {
                                                final days = GoogleSheetsApi.calculateDaysSinceLastEaten(
                                                  panelDate: panelDate,
                                                  columnIndex: 3,
                                                  foodId: food.id,
                                                );
                                                if (days == -1) return 'last eaten: --';
                                                return 'last eaten: $days day(s) ago';
                                              }(),
                                              style: TextStyle(color: fadedGrey, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
      
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    )
  );
}

tellMeDaFood(yes) {
  print(yes);
}