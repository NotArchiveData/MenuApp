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
          color: isToday ? cyanBg : darkGrey,
        ),
        child: Column(
          children: [
            topBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: widget.height - 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildMealSection(3, "", 1),

                        const SizedBox(height: 20),

                        buildMealSection(4, "", 4),

                        const SizedBox(height: 20),

                        buildMealSection(8, "", 4),

                        const SizedBox(height: 20),
                        
                        buildMealSection(12, "", 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildMealSection(int no, String mealTitle, int numberOfButtons) {
    return MealSection(
      no: no,
      title: mealTitle,
      panelDate: widget.date,
      numberOfButtons: numberOfButtons,
    );
  }

  // day of week and date and month
  Widget topBar() {
    return Column(
      
      children: [
        const SizedBox(height: 20),
    
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.day,
              style: TextStyle(
                color: white,
                fontSize: secondaryText,
                fontWeight: FontWeight.w600,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),

            const SizedBox(width: 8),
          
            Text(
              dateChange(widget.date),
              style: TextStyle(
                color: white,
                fontSize: quaternaryText,
                fontWeight: FontWeight.w400,
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
  
      ],
    );
  }
}

// just to show dd-mmmm instead of yyyy-mm-dd at the top bar of each day
String dateChange(String inputDate) {
  DateTime parsedDate = DateTime.parse(inputDate);
  String day = DateFormat('d').format(parsedDate);
  String suffix;

  if (day.endsWith('1') && day != '11') {
    suffix = 'st';
  } else if (day.endsWith('2') && day != '12') {
    suffix = 'nd';
  } else if (day.endsWith('3') && day != '13') {
    suffix = 'rd';
  } else {
    suffix = 'th';
  }

  return '$day$suffix';
}

