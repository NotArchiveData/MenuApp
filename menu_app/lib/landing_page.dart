import 'package:flutter/material.dart';
import 'dart:async';

import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/top_bar.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day_list.dart';
import 'package:menu_app/variables/date.dart' as date;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int currentPageIndex = 0;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPageIndex);

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
    final list = GoogleSheetsApi.currentTransactions;

    final int todayIndex = list.indexWhere((row) => row[0] == todayDate);

    if (todayIndex != -1) {
      setState(() {
        currentPageIndex = todayIndex;
      });
      pageController.jumpToPage(todayIndex);
    }
  }

  // Reload the sheet data from the pull-to-refresh action.
  Future<void> _refreshTransactions() async {
    await GoogleSheetsApi.loadTransactions();
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
                  Container(width: 50, color: accent),
                  const SizedBox(width: tertiaryPadding),
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: mainBg,
                      onRefresh: _refreshTransactions,
                      child: GoogleSheetsApi.loading
                          ? const Center(child: CircularProgressIndicator())
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final double pageSpacing = 10.0;
                                final double pageHeight = constraints.maxHeight - pageSpacing;
                                final list = GoogleSheetsApi.currentTransactions;
                                final int itemCount = list.length;

                                Widget buildPage(int index) {
                                  final bool isCurrentPage = index == currentPageIndex;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: index == itemCount - 1 ? 0 : pageSpacing,
                                    ),
                                    child: SizedBox(
                                      height: pageHeight,
                                      child: DayList(
                                        date: list[index][0],
                                        day: list[index][1],
                                        breakfast_id: list[index][2],
                                        lunch_id: list[index][3],
                                        dinner_id: list[index][4],
                                        isCurrentPage: isCurrentPage,
                                        height: pageHeight,
                                      ),
                                    ),
                                  );
                                }

                                return PageView.builder(
                                  controller: pageController,
                                  scrollDirection: Axis.vertical,
                                  itemCount: itemCount,
                                  onPageChanged: (index) {
                                    setState(() {
                                      currentPageIndex = index;
                                    });
                                  },
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
          ],
        ),
      ),
    );
  }
}
   