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

  @override
  Widget build(BuildContext context) {
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
            buildButton(carbList),
            buildButton(nonVegList),
          ],
        ),

      ],
    );
  }

  Widget buildButton(Widget Function(BuildContext, String) function) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(  
        fixedSize: Size(0, 160),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: white
      ),

      onPressed: (){
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (context) => function(context, widget.panelDate),
        );
      },

      child: SizedBox.shrink(),
    );

  }
}

