import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/button.dart';
import 'package:menu_app/variables/date.dart';

// <--- main DayList class. The stuff for the entire panel ---> 
class DayList extends StatelessWidget {
  final String date;
  final String day;
  final double height;

  const DayList({
    super.key,
    required this.date,
    required this.day,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isToday = date == getDate();
    final DateTime panelDate = DateTime.parse(date);
    final DateTime currentToday = DateTime.parse(getDate());

    final Color panelColour = panelDate.isBefore(currentToday) && !isToday
        ? pastBg
        : panelDate.isAfter(currentToday) && !isToday
            ? futureBg
            : cyanBg;

    final Color buttonColour = panelDate.isBefore(currentToday) && !isToday
        ? pastLightBg
        : panelDate.isAfter(currentToday) && !isToday
            ? futureLightBg
            : lightCyanBg;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: panelColour,
        borderRadius: BorderRadius.circular(30), // Keeps the outer container looking curved
      ),
      child: Column(
        children: [
          topBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              // 💎 THE FIX: Create an inner, invisible curved mask right here!
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Adjust this value to dial in the inner curve style
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: height - 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        buildMealSection(3, 1, buttonColour),
                        mealTitle("Morning Drink"),

                        const SizedBox(height: 20),

                        buildMealSection(4, 4, buttonColour),
                        mealTitle("Breakfast"),

                        const SizedBox(height: 20),

                        buildMealSection(8, 4, buttonColour),
                        mealTitle("Lunch"),

                        const SizedBox(height: 20),

                        buildMealSection(12, 4, buttonColour),
                        mealTitle("Dinner"),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMealSection(int no, int numberOfButtons, Color buttonColour) {
    return MealSection(
      no: no,
      panelDate: date,
      numberOfButtons: numberOfButtons,
      buttonColour: buttonColour,
    );
  }

  // day of week and date and month
  Widget topBar() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
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
              dateChange(date),
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

  Widget mealTitle(String meal) {
    return Column(
      children: [
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 8, 0),
                height: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(width: 1, color: whiteText.withValues(alpha: 0.5)),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: whiteText.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, 3),
              child: Text(
                meal,
                style: TextStyle(
                  color: whiteText.withValues(alpha: 0.5),
                  fontSize: quaternaryText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 30, 0),
                height: 8, 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: whiteText.withValues(alpha: 0.5),
                      ),
                    ),
                    Container(width: 1, color: whiteText.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ],
        )
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

