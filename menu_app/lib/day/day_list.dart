import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/button.dart';
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
      borderRadius: BorderRadius.circular(30),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildMealSection(3, "Breakfast"),
                    buildMealSection(6, "Lunch"),
                    buildMealSection(9, "Dinner"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildMealSection(int no, String mealTitle) {
    return MealSection(
      no: no,
      title: mealTitle,
      panelDate: widget.date,
    );
  }

  // day of week and date and month
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

