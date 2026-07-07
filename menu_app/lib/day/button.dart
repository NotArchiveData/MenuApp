import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/food_list.dart';
import 'package:menu_app/gsheets_api.dart';

// The shared meal section widget that composes several dropdowns.
class MealSection extends StatefulWidget {
  final String title;
  final String panelDate;
  // couldnt name anything better but this is for the column number in the spreadsheet
  final int no;

  const MealSection({
    super.key,
    required this.title,
    required this.panelDate,
    required this.no,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {

  String getFoodNameFromId(String id, String ya) {
    if (id.isEmpty) return ya; // Fallback hint text
    
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
    final int carbCol = widget.no;
    final int dish1Col = widget.no + 1;
    final int dish2Col = widget.no + 2;

    // 3. Extract the active food IDs currently cached in memory
    // Note: account for 0-based list indexing vs 1-based sheet columns (subtract 1)
    String currentCarbId = "";
    String currentDish1Id = "";
    String currentDish2Id = "";

    if (rowIndex != -1 && (rowIndex - 2) < GoogleSheetsApi.calendarDates.length) {
      final rowData = GoogleSheetsApi.calendarDates[rowIndex - 2];
      if (rowData.length >= carbCol) currentCarbId = rowData[carbCol - 1];
      if (rowData.length >= dish1Col) currentDish1Id = rowData[dish1Col - 1];
      if (rowData.length >= dish2Col) currentDish2Id = rowData[dish2Col - 1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            buildButton(
              foodList,
              widget.no + 1,
              ["v", "nv"],
              getFoodNameFromId(currentDish1Id, "Dish"),
              rowIndex,
              dish1Col,
              index: 0,
              totalButtons: 4,
            ),
            buildButton(
              foodList,
              widget.no + 2,
              ["v", "nv"],
              getFoodNameFromId(currentDish2Id, "Dish"),
              rowIndex,
              dish2Col,
              index: 1,
              totalButtons: 4,
            ),
            buildButton(
              foodList,
              widget.no,
              ["c"],
              getFoodNameFromId(currentCarbId, "Carb"),
              rowIndex,
              carbCol,
              index: 2,
              totalButtons: 4,
            ),
            buildButton(
              foodList,
              widget.no,
              ["c"],
              getFoodNameFromId(currentCarbId, "Carb"),
              rowIndex,
              carbCol,
              index: 3,
              totalButtons: 4,
            ),

            const SizedBox(height: 20)
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
        color: lightCyanBg,
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
              color: lightCyanBg,
              borderRadius: borderRadius,
            ),
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
                        // Fill red if prefix contains "nv" for non-veg, otherwise green for veg/carb
                        color: prefix.contains("nv") 
                            ? nonVegCircle // Soft, muted red matching palette
                            : vegCircle, // Soft, muted green matching palette
                        border: Border.all(
                          color: iconOutline, // Constant light outline
                          width: 1,
                        ),
                      ),
                    ),
                                
                    const SizedBox(width: 20),
                                
                    Text(
                      displayLabel,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: tertiaryText, color: whiteText),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            
                if (displayLabel != "Select Item" && displayLabel != "Dish" && displayLabel != "Carb")
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Add your clear/delete cell selection state action here
                    },
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(Icons.delete_outline, color: Colors.white60, size: 20)
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

