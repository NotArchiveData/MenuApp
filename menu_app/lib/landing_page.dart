// import 'package:menu_app/total_books.dart';
// import 'package:menu_app/top_panel.dart';

import 'package:flutter/material.dart';
import 'dart:async';

// gsheets
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/top_bar.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day_list.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  // wait for data to be fetched from gsheets
  bool timerHasStarted = false;
  bool imagesPreloaded = false;

  @override
  void initState() {
    super.initState();

    // Start loading GSheets
    if (GoogleSheetsApi.loading) {
      startLoading();
    }
  }

  void startLoading() {
    timerHasStarted = true;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (GoogleSheetsApi.loading == false) {
        setState(() {});
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // main landing page
    return Scaffold(
      backgroundColor: mainBg,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [

            const SizedBox(height: primaryPadding),

            TopBar(),

            const SizedBox(height: secondaryPadding),
          
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Container(
                    width: 50,
                    color: accent,
                  ),

                  const SizedBox(width: tertiaryPadding),

                  // Day list
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: mainBg,
                      onRefresh: () async {
                        await GoogleSheetsApi.loadTransactions();
                        setState(() {});
                      },

                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: GoogleSheetsApi.loading == true ? const Center(
                          child: CircularProgressIndicator(),
                        ) : ListView.builder(
                          itemCount: GoogleSheetsApi.currentTransactions.length,
                          itemBuilder: (context, index) {
                            final reversedList = GoogleSheetsApi.currentTransactions.reversed.toList();

                            return DayList(
                              date: reversedList[index][0],            // e.g., Date
                              day: reversedList[index][1],            // e.g., Day of the week
                              breakfast_id: reversedList[index][2], // e.g., Breakfast (Initially "" if empty)
                              lunch_id: reversedList[index][3],           // e.g., Lunch (Initially "" if empty)
                              dinner_id: reversedList[index][4],           // e.g., Dinner (Initially "" if empty)
                            );
                        }),
                      ),
                    )
                  ),
                ],
              ),
            ),

            const SizedBox(height: secondaryPadding),


          ]
        ),
      )
    );
  }
}   