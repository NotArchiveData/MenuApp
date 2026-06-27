import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/variables/date.dart' as date;



class DayList extends StatefulWidget {
  final String date;
  final String day;
  final String breakfast_id;
  final String lunch_id;
  final String dinner_id;

  const DayList({super.key, 
    required this.date,
    required this.day,
    required this.breakfast_id,
    required this.lunch_id,
    required this.dinner_id,
  });

  @override
  State<DayList> createState() => _DayListState();
}

class _DayListState extends State<DayList> {

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {

    // 1. Check if this card's date matches today's actual date
    final bool isToday = widget.date == date.getDate();

    return Column(
      children: [

        // main rectangle
        ClipRRect(
          borderRadius: BorderRadius.circular(15),

          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isExpanded ? 130 : 70,
              decoration: BoxDecoration(
                color: isToday ? accent : darkGrey,
              ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
            
                          // thin rectangle design on the left
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 8,
                            height: isExpanded ? 90 : 40,
                            decoration: BoxDecoration(
                                color: fundGreen,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5),
                                )
                            ),
                          ),
            
                          SizedBox(width: 15),
                          
                          // main transaction + time and date
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 220),
                                child: Text(
                                  widget.date,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textHeightBehavior: TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                )
                              ),
          
                              SizedBox(height:2),
                          
                              Text(
                                "${widget.day}, ${widget.date}",
                                style: TextStyle(
                                  color: mediumGrey,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],  
                  ),
                )
            ),
          ),
        ),

        SizedBox(height:10),
      ],
    );
  }
}