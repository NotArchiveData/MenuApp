// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:menu_app/constants/colours.dart';
// import 'package:menu_app/gsheets_api.dart';

// Widget dishList(BuildContext context, String panelDate, int columnNumberToAddFood) {
//   final List<FoodOption> carbOptions = GoogleSheetsApi.getFoodOptionsByPrefix(["nv", "v"]);
  
//   return Dialog(
//     backgroundColor: Colors.transparent,
//     insetPadding: EdgeInsets.zero,
//     child: ConstrainedBox(
//       constraints: const BoxConstraints(
//         maxHeight: 450, 
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//         child: Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF2b2b2b),
//             border: Border.all(color: accent), 
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 20),
      
//               // Title
//               const Text(
//                 "Select Dish",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
      
//               const SizedBox(height: 20),
      
//               // 2. 💎 THE LIVE DATA LIST SECTION
//               Flexible(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: carbOptions.isEmpty
//                       ? const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Text("No carbs found", style: TextStyle(color: Colors.white70)),
//                         )
//                       : SingleChildScrollView(
//                           physics: const BouncingScrollPhysics(), // 💎 Smooth, adaptive iOS/Android bounce scrolling
//                           child: Column(
//                             children: carbOptions.map((food) {
//                               return Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(12),
//                                   onTap: () async {
//                                     HapticFeedback.lightImpact();
//                                     Navigator.of(context).pop(food); // Close dialog and get selected food option

//                                     // 1. Instantly pinpoint the row index for THIS specific panel's calendar date
//                                     int targetRowIndex = GoogleSheetsApi.findRowIndexByDate(panelDate);

//                                     if (targetRowIndex != -1) {
//                                       // 2. Overwrite the exact cell directly without complex string manipulations!
//                                       await GoogleSheetsApi.updateSingleMealSlot(
//                                         rowIndex: targetRowIndex,
//                                         columnIndex: columnNumberToAddFood, // e.g., 3 for Breakfast-Carb, 6 for Lunch-Carb
//                                         foodId: food.id,
//                                       );
//                                     } else {
//                                       print("Could not find a row match for date: $panelDate");
//                                     }
//                                   },
//                                   splashColor: Colors.white12,
//                                   highlightColor: Colors.white10,
//                                   child: Container(
//                                     width: double.infinity,
//                                     padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//                                     margin: const EdgeInsets.only(bottom: 8),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withValues(alpha: 0.05),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           food.name,
//                                           style: const TextStyle(color: Colors.white, fontSize: 15),
//                                         ),
//                                         Text(
//                                           food.id.toUpperCase(),
//                                           style: TextStyle(color: fadedGrey, fontSize: 12),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                 ),
//               ),
      
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     )
//   );
// }

// tellMeDaFood(yes) {
//   print(yes);
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/gsheets_api.dart';

Widget dishList(BuildContext context, String panelDate, int columnNumberToAddFood) {
  final List<FoodOption> masterOptions = GoogleSheetsApi.getFoodOptionsByPrefix(["nv", "v"]);
  final TextEditingController searchController = TextEditingController();
  
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
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              // Step 2: Derive filteredOptions from the current search query
              List<FoodOption> filteredOptions;
              if (searchController.text.isEmpty) {
                filteredOptions = masterOptions;
              } else {
                filteredOptions = masterOptions
                    .where((food) => food.name.toLowerCase().contains(searchController.text.toLowerCase()))
                    .toList();
              }
              
              // <--- MAIN POPUP --->
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
          
                  // Title
                  const Text(
                    "Select Dish",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          
                  const SizedBox(height: 16),
          
                  // Step 3: Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search..',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: secondaryText,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                      ),
                      
                      // Step 4: Trigger rebuild on text change (filtering is derived from searchController.text)
                      onChanged: (String query) {
                        setModalState(() {
                          // Trigger rebuild - filtering happens automatically above
                        });
                      },
                    ),
                  ),
          
                  const SizedBox(height: 16),
          
                  // Step 5: THE LIVE DATA LIST SECTION (now using filteredOptions)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: filteredOptions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text("No foods", style: TextStyle(color: Colors.white70)),
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(), // 💎 Smooth, adaptive iOS/Android bounce scrolling
                              child: Column(
                                children: filteredOptions.map((food) {
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
                                            columnIndex: columnNumberToAddFood, // e.g., 3 for Breakfast-Carb, 6 for Lunch-Carb
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
                                                      columnIndices: [4, 5, 7, 8, 10, 11],
                                                      foodId: food.id,
                                                    );
                                                    if (days == -1) return 'Never eaten';
                                                    if (days == 1) return 'Ate yesterday';
                                                    return 'Ate $days days ago';
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
              );
            },
          ),
        ),
      ),
    )
  );
}
