import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/drop_down.dart';
import 'package:menu_app/variables/date.dart';

// <--- main DayList class. The stuff for the entire panel ---> 
class DayList extends StatefulWidget {
  final String date;
  final String day;
  final bool isCurrentPage;
  final double height;

  const DayList({
    super.key,
    required this.date,
    required this.day,
    required this.isCurrentPage,
    required this.height,
  });

  @override
  State<DayList> createState() => _DayListState();
}

class _DayListState extends State<DayList> {
  @override
  Widget build(BuildContext context) {
    final bool isToday = widget.date == getDate();

    return ClipRRect(
      // the main large rectangle day panel
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: isToday ? accent : darkGrey,
        ),
        child: Column(
          children: [
            // Top section with day name, date, and divider.
            topBar(),

            // The meals
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(tertiaryPadding),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildMealSection("Breakfast", ["breakfast-dish-1", "breakfast-dish-2", "breakfast-carb"]),

                      const SizedBox(height: 12),

                      buildMealSection("Lunch", ["lunch-dish-1", "lunch-dish-2", "lunch-carb"]),

                      const SizedBox(height: 12),
                      
                      buildMealSection("Dinner", ["dinner-dish-1", "dinner-dish-2", "dinner-carb"]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildMealSection(String mealTitle, List<String> keys) {
    // We match the keys you pass in with their constant layout rules
    final List<DropdownConfig> autoConfigs = [
      DropdownConfig(
        key: keys[0], 
        hintText: 'Dish', 
        prefixes: ['v', 'nv'], // Adjusted to accept both based on your earlier prompt!
      ),
      DropdownConfig(
        key: keys[1], 
        hintText: 'Dish', 
        prefixes: ['v', 'nv'],
      ),
      DropdownConfig(
        key: keys[2], 
        hintText: 'Carb', 
        prefixes: ['c'],
      ),
    ];

    // Return the actual external widget populated with the generated data
    return MealSection(
      title: mealTitle,
      dropdownConfigs: autoConfigs,
    );
  }

  // day of week and date and month
  // see if you wish to add an "update" button in this. so when the menu is set, just press update. although a better UX would be auto update when any item from the drop down is pressed
  Widget topBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: tertiaryPadding),
    
        Text(
          widget.day,
          style: TextStyle(
            color: white,
            fontSize: primaryText,
            fontWeight: FontWeight.w600,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),

        const SizedBox(height: 2),
        
        Text(
          dateChange(widget.date),
          style: TextStyle(
            color: white,
            fontSize: secondaryText,
            fontWeight: FontWeight.w400,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
        
        const SizedBox(height: tertiaryPadding),
    
        Container(
          width: double.infinity,
          height: 1,
          color: white,
        )
      ],
    );
  }
}

// just to show dd-mmmm instead of yyyy-mm-dd at the top bar of each day
String dateChange(String inputDate) {
  DateTime parsedDate = DateTime.parse(inputDate);
  String day = DateFormat('d').format(parsedDate);       
  String month = DateFormat('MMMM').format(parsedDate); 
  String suffix;

  // 3. Apply your ordinal suffix logic
  if (day.endsWith('1') && day != '11') {
    suffix = 'st';
  } else if (day.endsWith('2') && day != '12') {
    suffix = 'nd';
  } else if (day.endsWith('3') && day != '13') {
    suffix = 'rd';
  } else {
    suffix = 'th';
  }

  return '$day$suffix $month';
}

