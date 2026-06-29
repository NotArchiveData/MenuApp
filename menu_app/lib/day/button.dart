import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/food/carb_list.dart';
import 'package:menu_app/food/nonveg_list.dart';
import 'package:menu_app/gsheets_api.dart';

// The shared meal section widget that composes several dropdowns.
class MealSection extends StatefulWidget {
  final String title;
  final String panelDate;

  const MealSection({
    super.key,
    required this.title,
    required this.panelDate,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {

  String getFoodNameFromId(String id) {
    if (id.isEmpty) return "Select Item"; // Fallback hint text
    
    // Find matching item in your pre-loaded GoogleSheetsApi.foodItems cache
    final match = GoogleSheetsApi.foodItems.firstWhere(
      (row) => row.isNotEmpty && row.first.trim().toLowerCase() == id.trim().toLowerCase(),
      orElse: () => [],
    );

    // If found, return column 2 (index 1), else return the raw ID as a fallback
    return match.length > 1 ? match[1].trim() : id;
  }

  // Calculates the correct column index dynamically
  int getColumnIndex(String type) {
    int baseOffset = 3; // Breakfast columns start at 3
    if (widget.title == "Lunch") baseOffset = 6;
    if (widget.title == "Dinner") baseOffset = 9;

    if (type == "carb") return baseOffset;       // e.g., 3, 6, 9
    if (type == "dish1") return baseOffset + 1;  // e.g., 4, 7, 10
    return baseOffset + 2;                       // e.g., 5, 8, 11 (dish2)
  }

  @override
  Widget build(BuildContext context) {
    // 1. Locate the correct row for this panel's date
    final int rowIndex = GoogleSheetsApi.findRowIndexByDate(widget.panelDate);

    // 2. Resolve the targeted column numbers
    final int carbCol = getColumnIndex("carb");
    final int dish1Col = getColumnIndex("dish1");

    // 3. Extract the active food IDs currently cached in memory
    // Note: account for 0-based list indexing vs 1-based sheet columns (subtract 1)
    String currentCarbId = "";
    String currentDish1Id = "";

    if (rowIndex != -1 && (rowIndex - 2) < GoogleSheetsApi.calendarDates.length) {
      final rowData = GoogleSheetsApi.calendarDates[rowIndex - 2];
      if (rowData.length >= carbCol) currentCarbId = rowData[carbCol - 1];
      if (rowData.length >= dish1Col) currentDish1Id = rowData[dish1Col - 1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: white,
            fontSize: secondaryText,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 8),
        
        Row(
          children: [
            // Pass the resolved string names and layout specs down
            Expanded(child: buildButton(carbList, getFoodNameFromId(currentCarbId), rowIndex, carbCol)),
            const SizedBox(width: 8),
            Expanded(child: buildButton(nonVegList, getFoodNameFromId(currentDish1Id), rowIndex, dish1Col)), // Replace with nonVegList as needed
          ],
        ),
      ],
    );
  }

  // 1. Update the signature definition inside buildButton's parameter list:
  Widget buildButton(
    Widget Function(BuildContext, String) builderFunction, // 💎 Matches (context, date) perfectly
    String displayLabel, 
    int rowIndex, 
    int colIndex,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(  
        fixedSize: const Size(0, 60), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: white,
      ),
      onPressed: () async {
        HapticFeedback.lightImpact();
        
        // 2. 💎 Pass BOTH the required context and your layout's panelDate into your custom builder here:
        final selectedFood = await showDialog<FoodOption>(
          context: context,
          builder: (dialogContext) => builderFunction(dialogContext, widget.panelDate),
        );

        // 3. Keep the local state cache updated when an item returns
        if (selectedFood != null && rowIndex != -1) {
          setState(() {
            GoogleSheetsApi.calendarDates[rowIndex - 2][colIndex - 1] = selectedFood.id;
          });
          
          // Note: The database write happens inside carb_list.dart onTap, 
          // so you don't even need to call updateSingleMealSlot here anymore!
        }
      },
      child: Text(
        displayLabel,
        style: const TextStyle(fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}

