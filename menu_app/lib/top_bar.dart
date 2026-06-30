import 'package:menu_app/constants/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/variables/date.dart' as date;
import 'package:url_launcher/url_launcher.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Meal Prep", 
              style: TextStyle(
                color: text,
                fontSize: secondaryText,
                fontWeight: FontWeight.w400,
                ),
            ),
          
            Text(
              date.getDayMonthYear(),
              style: TextStyle(
                color: text,
                fontSize: primaryText,
                fontWeight: FontWeight.w600,
                ),
              textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
            )
          ],
        ),
    
        // icon to go to spreadsheets
        Material(
          color: accent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              GoogleSheetsApi.refreshData();
              //launchUrl(Uri.parse("https://docs.google.com/spreadsheets/d/1pj_bQgIMRJRG4BAiZQ-nqB8xYQIJVGGAFlt0T3IKJYU/edit?usp=sharing"));
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              // child: Icon(Icons.exit_to_app, color: Colors.white),
              child: Icon(Icons.refresh, color: Colors.white)
            ),
          ),
        ),
      ],
    );
  }
}