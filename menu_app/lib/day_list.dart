import 'package:flutter/material.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/variables/date.dart';

class DayList extends StatelessWidget {
  final String date;
  final String day;
  final String breakfast_id;
  final String lunch_id;
  final String dinner_id;
  final bool isCurrentPage;
  final double height;

  const DayList({
    super.key,
    required this.date,
    required this.day,
    required this.breakfast_id,
    required this.lunch_id,
    required this.dinner_id,
    required this.isCurrentPage,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isToday = date == getDate();
    final double indicatorHeight = isCurrentPage ? 90 : 40;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isToday ? accent : darkGrey,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Container(
                width: 8,
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: fundGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(child: _buildTextColumn()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$day, $date",
          style: TextStyle(
            color: mediumGrey,
            fontSize: 8,
            fontWeight: FontWeight.w400,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ],
    );
  }
}
