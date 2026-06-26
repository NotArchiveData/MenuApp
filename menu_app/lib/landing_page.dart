// import 'package:menu_app/total_books.dart';
// import 'package:menu_app/top_panel.dart';

import 'package:flutter/material.dart';
import 'dart:async';

// gsheets
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/top_bar.dart';
import 'package:menu_app/constants/common_values.dart';

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

                  Expanded(
                    child: Container(
                      color: accent,
                    ),
                  )
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