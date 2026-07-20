import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/button.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/ingredients.dart';
import 'package:menu_app/variables/date.dart';

class DayList extends StatefulWidget {
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
  State<DayList> createState() => _DayListState();
}

class _DayListState extends State<DayList> {
  @override
  Widget build(BuildContext context) {
    final bool isToday = widget.date == getDate();
    final DateTime panelDate = DateTime.parse(widget.date);
    final DateTime currentToday = DateTime.parse(getDate());

    final Color panelColour = panelDate.isBefore(currentToday) && !isToday
        ? pastBg
        : panelDate.isAfter(currentToday) && !isToday
            ? futureBg
            : presentBg;

    final Color buttonColour = panelDate.isBefore(currentToday) && !isToday
        ? pastLightBg
        : panelDate.isAfter(currentToday) && !isToday
            ? futureLightBg
            : presentLightBg;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: panelColour,
        borderRadius: BorderRadius.circular(rounding),
      ),
      child: Column(
        children: [
          topBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(rounding),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: widget.height - 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        mealTitle("Morning Drink"),
                        buildMealSection(3, 1, buttonColour),
                        const SizedBox(height: 25),
                        mealTitle("Breakfast"),
                        buildMealSection(4, 4, buttonColour),
                        const SizedBox(height: 25),
                        mealTitle("Lunch"),
                        buildMealSection(8, 4, buttonColour),
                        const SizedBox(height: 25),
                        mealTitle("Dinner"),
                        buildMealSection(12, 4, buttonColour),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomBar(context),
        ],
      ),
    );
  }

  Widget buildMealSection(int no, int numberOfButtons, Color buttonColour) {
    return MealSection(
      no: no,
      panelDate: widget.date,
      numberOfButtons: numberOfButtons,
      buttonColour: buttonColour,
    );
  }

  Widget topBar() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.day,
              style: TextStyle(color: white, fontSize: secondaryText, fontWeight: FontWeight.w600),
              textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
            ),
            const SizedBox(width: 8),
            Text(
              dateChange(widget.date),
              style: TextStyle(color: white, fontSize: quaternaryText, fontWeight: FontWeight.w400),
              textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget bottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.white12,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                showIngredientsDialog(context, widget.date);
              },
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SvgPicture.asset(
                  "assets/icons/ingredients.svg",
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  height: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.white12,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();

                final hasExisting = GoogleSheetsApi.dayHasExistingSelections(widget.date);

                if (hasExisting) {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF2b2b2b),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text("Overwrite selections?", style: TextStyle(color: Colors.white)),
                      content: const Text(
                        "This day already has some food selected. Autofill will overwrite all of it.",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Overwrite", style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return;
                }

                // Instant: update in-memory data and rebuild the UI right away.
                GoogleSheetsApi.autofillDayLocal(widget.date);
                setState(() {});

                // Slow: sync to the sheet in the background, no await, no blocking.
                GoogleSheetsApi.syncRowToSheet(widget.date).catchError((e) {
                  print("Autofill sync failed: $e");

                });
              },
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Icon(Icons.shuffle, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mealTitle(String meal) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(30, 0, 8, 0),
                height: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 1, color: whiteText.withValues(alpha: 0.5)),
                    Expanded(child: Container(height: 1, color: whiteText.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -3),
              child: Text(
                meal,
                style: TextStyle(color: whiteText.withValues(alpha: 0.5), fontSize: quaternaryText, fontWeight: FontWeight.w400),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 30, 0),
                height: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container(height: 1, color: whiteText.withValues(alpha: 0.5))),
                    Container(width: 1, color: whiteText.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}

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