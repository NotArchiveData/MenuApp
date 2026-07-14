import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/select_food.dart';
import 'package:menu_app/gsheets_api.dart';

// The shared meal section widget that composes several dropdowns.
class MealSection extends StatefulWidget {
  final String panelDate;
  // couldnt name anything better but this is for the column number in the spreadsheet
  final int no;
  final int numberOfButtons;
  final Color buttonColour;

  const MealSection({
    super.key,
    required this.panelDate,
    required this.no,
    required this.numberOfButtons,
    required this.buttonColour,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {

  String getFoodNameFromId(String id) {
    if (id.isEmpty) return "Select Dish"; // Fallback hint text
    
    // Find matching item in your pre-loaded GoogleSheetsApi.foodItems cache
    final match = GoogleSheetsApi.foodItems.firstWhere(
      (row) => row.isNotEmpty && row.first.trim().toLowerCase() == id.trim().toLowerCase(),
      orElse: () => [],
    );

    // If found, return column 2 (index 1), else return the raw ID as a fallback
    return match.length > 1 ? match[1].trim() : id;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Locate the correct row for this panel's date
    final int rowIndex = GoogleSheetsApi.findRowIndexByDate(widget.panelDate);

    // 2. Resolve the targeted column numbers
    final int drinkCol = widget.no;
    final int dish1Col = widget.no;
    final int dish2Col = widget.no + 1;
    final int dish3Col = widget.no + 2;
    final int dish4Col = widget.no + 3;

    // 3. Extract the active food IDs currently cached in memory
    // Note: account for 0-based list indexing vs 1-based sheet columns (subtract 1)
    String currentDrinkId = "";
    String currentDish1Id = "";
    String currentDish2Id = "";
    String currentDish3Id = "";
    String currentDish4Id = "";

    if (rowIndex != -1 && (rowIndex - 2) < GoogleSheetsApi.calendarDates.length) {
      final rowData = GoogleSheetsApi.calendarDates[rowIndex - 2];
      if (rowData.length >= drinkCol) currentDrinkId = rowData[drinkCol - 1];
      if (rowData.length >= dish1Col) currentDish1Id = rowData[dish1Col - 1];
      if (rowData.length >= dish2Col) currentDish2Id = rowData[dish2Col - 1];
      if (rowData.length >= dish3Col) currentDish3Id = rowData[dish3Col - 1];
      if (rowData.length >= dish4Col) currentDish4Id = rowData[dish4Col - 1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.numberOfButtons == 4) Column(
          children: [
            buildButton(
              simpleFoodDialog,
              widget.no,
              ["v", "nv", "c", "f", "s"],
              currentDish1Id,
              getFoodNameFromId(currentDish1Id),
              rowIndex,
              dish1Col,
              index: 0,
              totalButtons: 4,
            ),
            buildButton(
              simpleFoodDialog,
              widget.no + 1,
              ["v", "nv"],
              currentDish2Id,
              getFoodNameFromId(currentDish2Id),
              rowIndex,
              dish2Col,
              index: 1,
              totalButtons: 4,
            ),
            buildButton(
              simpleFoodDialog,
              widget.no + 2,
              ["c"],
              currentDish3Id,
              getFoodNameFromId(currentDish3Id),
              rowIndex,
              dish3Col,
              index: 2,
              totalButtons: 4,
            ),
            buildButton(
              simpleFoodDialog,
              widget.no + 3,
              ["v", "nv"],
              currentDish4Id,
              getFoodNameFromId(currentDish4Id),
              rowIndex,
              dish4Col,
              index: 3,
              totalButtons: 4,
            ),
          ],
        ),

        if (widget.numberOfButtons == 1) Column(
          children: [
            buildButton(
              simpleFoodDialog,
              widget.no,
              ["d"],
              currentDrinkId,
              getFoodNameFromId(currentDrinkId),
              rowIndex,
              drinkCol,
              index: 0,
              totalButtons: 1,
            ),
          ],
        ),
      ],
    );
  }

  // 1. Update the signature definition inside buildButton's parameter list:
  Widget buildButton(
    Widget Function(BuildContext, String, int, List<String>) builderFunction, 
    int columnNumberToAddFood,
    List<String> prefix,
    String foodId,
    String displayLabel, 
    int rowIndex, 
    int colIndex, {
    required int index,
    required int totalButtons,
  }) {
    final bool isFirst = index == 0;
    final bool isLast = index == totalButtons - 1;
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(20) : Radius.zero,
      topRight: isFirst ? const Radius.circular(20) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(20) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(20) : Radius.zero,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 2),
      child: Material(
        color: widget.buttonColour,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();

            final selectedFood = await showDialog<FoodOption>(
              context: context,
              builder: (dialogContext) => builderFunction(dialogContext, widget.panelDate, columnNumberToAddFood, prefix),
            );

            if (selectedFood != null && rowIndex != -1) {
              setState(() {
                GoogleSheetsApi.calendarDates[rowIndex - 2][colIndex - 1] = selectedFood.id;
              });
            }
          },
          borderRadius: borderRadius,
          splashColor: Colors.white12,
          highlightColor: Colors.white10,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: widget.buttonColour,
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: getCircleColorFromId(foodId),
                          border: Border.all(
                            color: iconOutline, // Constant light outline
                            width: 1,
                          ),
                        ),
                      ),
                                  
                      const SizedBox(width: 12),
                                  
                      Text(
                        displayLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: tertiaryText, 
                          color: displayLabel == "Select Dish" ? whiteText.withValues(alpha: 0.5) : whiteText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              
                  // delete item
                  if (displayLabel != "Select Dish")
                    InkWell(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        if (rowIndex != -1) {
                          setState(() {
                            GoogleSheetsApi.calendarDates[rowIndex - 2][colIndex - 1] = ""; 
                          });
              
                          try {
                            // 2. Clear the exact cell directly in your Google Sheet in the background
                            await GoogleSheetsApi.updateSingleMealSlot(
                              rowIndex: rowIndex,
                              columnIndex: columnNumberToAddFood, // e.g., 3 for Breakfast-Carb, 4 for Breakfast-Dish
                              foodId: "", // Passing an empty string clears the cell content
                            );
                          } catch (e) {
                            print("Error clearing spreadsheet cell: $e");
                            // Optional: Handle rollback if the network call fails completely
                          }
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Icon(Icons.delete_outline, color: Colors.white60, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

