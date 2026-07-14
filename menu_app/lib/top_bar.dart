import 'package:flutter_svg/svg.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/variables/date.dart' as date;

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Meal Prep", 
                style: TextStyle(
                  color: text,
                  fontSize: quaternaryText,
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

          Row(
            children: [
              Material(
                color: cyanBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    GoogleSheetsApi.refreshData();
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    // child: Icon(Icons.exit_to_app, color: Colors.white),
                    child: Icon(Icons.shopping_cart_outlined, color: Colors.white70)
                  ),
                ),
              ),

              SizedBox(width: 5),
                    
              // icon to go to spreadsheets
              Material(
                color: cyanBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    GoogleSheetsApi.refreshData();
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    // child: Icon(Icons.exit_to_app, color: Colors.white),
                    child: Icon(Icons.refresh, color: Colors.white70)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}