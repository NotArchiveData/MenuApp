import 'package:flutter/material.dart';
import 'dart:async';

import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/top_bar.dart';
import 'package:menu_app/day/day_list.dart';
import 'package:menu_app/navbar.dart';
import 'package:menu_app/variables/date.dart' as date;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
    );

    if (GoogleSheetsApi.loading) {
      _waitForSheetData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToToday();
      });
    }
  }

  // Keep checking until the Google Sheet data has finished loading.
  void _waitForSheetData() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!GoogleSheetsApi.loading) {
        timer.cancel();
        if (!mounted) return;
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _jumpToToday();
        });
      }
    });
  }

  // Scroll the page view to today's date if it exists in the list.
  void _jumpToToday() {
    final todayDate = date.getDate();
    final list = GoogleSheetsApi.calendarDates;
    final int todayIndex = list.indexWhere((row) => row[0] == todayDate);

    if (todayIndex != -1 && mounted) {
      pageController.jumpToPage(todayIndex);
    }
  }

  // Reload the sheet data from the pull-to-refresh action.
  Future<void> _refreshTransactions() async {
    await GoogleSheetsApi.refreshData();
    setState(() {});
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            TopBar(),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                color: Colors.white,
                backgroundColor: mainBg,
                onRefresh: _refreshTransactions,
                child: GoogleSheetsApi.loading
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          const double pageSpacing = 10.0;
                          final double pageHeight = constraints.maxHeight - pageSpacing;
                          final list = GoogleSheetsApi.calendarDates;
                          final int itemCount = list.length;
                            
                          Widget buildPage(int index) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: SizedBox(
                                height: pageHeight,
                                child: DayList(
                                  date: list[index][0],
                                  day: list[index][1],
                                  height: pageHeight,
                                ),
                              ),
                            );
                          }
                            
                          return PageView.builder(
                            controller: pageController,
                            scrollDirection: Axis.horizontal,
                            padEnds: false,
                            physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              return buildPage(index);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: const NavBar(),
        ),
      ),
    );
  }
}
   