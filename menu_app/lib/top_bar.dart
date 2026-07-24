import 'package:menu_app/constants/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/grocerylist_page.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/testingg/pdf_viewer_test.dart';
import 'package:menu_app/variables/date.dart' as date;
import 'package:flutter/cupertino.dart';
import 'package:menu_app/testingg/diet_import.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onRefresh;

  const TopBar({
    super.key,
    this.onRefresh,
  });

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

              // icon to go to grocery list
              Material(
                color: presentBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // GoogleSheetsApi.loadGroceryList();
                    
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const GroceryListPage(),
                      ),
                    );
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
                    
              // icon to import pdf
              Material(
                color: presentBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await importDietPlanFromJson(context, mockDietPlanJson);
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    // child: Icon(Icons.exit_to_app, color: Colors.white),
                    child: Icon(Icons.import_export, color: Colors.white70)
                  ),
                ),
              ),

              Material(
                color: presentBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await pickAndSendPdf(context);
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.picture_as_pdf, color: Colors.white70),
                  ),
                ),
              ),

              SizedBox(width: 5),
                    
              // icon to reload data
              Material(
                color: presentBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await GoogleSheetsApi.refreshData();
                    onRefresh?.call(); // Triggers rebuild in the parent widget
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