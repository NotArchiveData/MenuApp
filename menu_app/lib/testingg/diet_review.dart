import 'package:flutter/material.dart';
import 'package:menu_app/day/add_dish.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/testingg/diet_import.dart';

enum MatchStatus { matched, needsReview, notFound }

class DishMatch {
  final String dateString;
  final int dayOffset;
  final String mealLabel;
  final int columnIndex;
  final String parsedName;
  String? matchedId;
  String matchedName;
  double score;
  final List<MapEntry<String, double>> candidates; // name -> score, top few

  DishMatch({
    required this.dateString,
    required this.dayOffset,
    required this.mealLabel,
    required this.columnIndex,
    required this.parsedName,
    required this.matchedId,
    required this.matchedName,
    required this.score,
    required this.candidates,
  });

  MatchStatus get status {
    if (matchedId == null || matchedId!.isEmpty) return MatchStatus.notFound;
    if (score >= 0.6) return MatchStatus.matched;
    return MatchStatus.needsReview;
  }

  Color get statusColor {
    switch (status) {
      case MatchStatus.matched:
        return Colors.green;
      case MatchStatus.needsReview:
        return Colors.orange;
      case MatchStatus.notFound:
        return Colors.red;
    }
  }
}

// Builds the full list of dish matches for every day/meal/slot, WITHOUT
// writing anything to the sheet — this is purely for the review screen.
List<DishMatch> buildDishMatches({
  required WeeklyDietPlan plan,
  required List<List<String>> foodItems,
  DateTime? startDate,
}) {
  final baseDate = startDate ?? DateTime.now();
  const breakfastCols = [4, 5, 6, 7];
  const lunchCols = [8, 9, 10, 11];
  const dinnerCols = [12, 13, 14, 15];

  final List<DishMatch> results = [];

  final sortedDays = plan.dailyPlans.keys.toList()..sort();

  for (final dayOffset in sortedDays) {
    final dayMeals = plan.dailyPlans[dayOffset]!;
    final dateString = baseDate.add(Duration(days: dayOffset)).toIso8601String().split('T').first;

    void processMeal(List<String> names, List<int> cols, String label) {
      for (int i = 0; i < cols.length && i < names.length; i++) {
        final parsedName = names[i];
        final scored = scoreAllCandidates(parsedName, foodItems);
        final top = scored.take(3).toList();

        String? bestId;
        String bestName = "";
        double bestScore = 0.0;

        if (top.isNotEmpty && top.first.value >= 0.35) {
          bestId = top.first.key[0].trim();
          bestName = top.first.key[1].trim();
          bestScore = top.first.value;
        }

        results.add(DishMatch(
          dateString: dateString,
          dayOffset: dayOffset,
          mealLabel: label,
          columnIndex: cols[i],
          parsedName: parsedName,
          matchedId: bestId,
          matchedName: bestName,
          score: bestScore,
          candidates: top.map((e) => MapEntry(e.key[1].trim(), e.value)).toList(),
        ));
      }
    }

    processMeal(dayMeals.breakfast, breakfastCols, "Breakfast");
    processMeal(dayMeals.lunch, lunchCols, "Lunch");
    processMeal(dayMeals.dinner, dinnerCols, "Dinner");
  }

  return results;
}

// Returns EVERY food item scored against parsedName, sorted best-first —
// used both for the console log and for populating the review screen's
// "pick a different match" list.
List<MapEntry<List<String>, double>> scoreAllCandidates(
  String parsedName,
  List<List<String>> foodItems,
) {
  final targetClean = FoodMatcher.normalizeText(parsedName);
  final List<MapEntry<List<String>, double>> scored = [];

  for (final row in foodItems) {
    if (row.length < 2) continue;
    final dbNameClean = FoodMatcher.normalizeText(row[1].trim());
    if (dbNameClean.isEmpty) continue;

    final score = targetClean == dbNameClean
        ? 1.0
        : FoodMatcher.calculateSimilarity(targetClean, dbNameClean);

    scored.add(MapEntry(row, score));
  }

  scored.sort((a, b) => b.value.compareTo(a.value));
  return scored;
}

class DietReviewPage extends StatefulWidget {
  final List<DishMatch> matches;

  const DietReviewPage({super.key, required this.matches});

  @override
  State<DietReviewPage> createState() => _DietReviewPageState();
}

class _DietReviewPageState extends State<DietReviewPage> {
  late List<DishMatch> matches;

  @override
  void initState() {
    super.initState();
    matches = widget.matches;
  }

  Map<int, List<DishMatch>> get groupedByDay {
    final Map<int, List<DishMatch>> grouped = {};
    for (final m in matches) {
      grouped.putIfAbsent(m.dayOffset, () => []).add(m);
    }
    return grouped;
  }

  Future<void> openDishOptions(DishMatch dish) async {
    final searchController = TextEditingController();
    List<List<String>> searchResults = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("From PDF: '${dish.parsedName}'", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Currently matched: ${dish.matchedName.isEmpty ? '(none)' : dish.matchedName}"),
                  const Divider(height: 24),

                  const Text("Top candidates:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...dish.candidates.map((c) => ListTile(
                        title: Text(c.key),
                        subtitle: Text("score: ${c.value.toStringAsFixed(2)}"),
                        onTap: () {
                          final match = GoogleSheetsApi.foodItems.firstWhere(
                            (row) => row.length > 1 && row[1].trim() == c.key,
                            orElse: () => [],
                          );
                          if (match.isNotEmpty) {
                            setState(() {
                              dish.matchedId = match[0].trim();
                              dish.matchedName = match[1].trim();
                              dish.score = c.value;
                            });
                          }
                          Navigator.pop(context);
                        },
                      )),

                  const Divider(height: 24),
                  const Text("Or search all foods:", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(hintText: "Type to search..."),
                    onChanged: (query) {
                      final q = query.trim().toLowerCase();
                      setSheetState(() {
                        searchResults = q.isEmpty
                            ? []
                            : GoogleSheetsApi.foodItems
                                .where((row) => row.length > 1 && row[1].toLowerCase().contains(q))
                                .take(10)
                                .toList();
                      });
                    },
                  ),
                  ...searchResults.map((row) => ListTile(
                        title: Text(row[1]),
                        onTap: () {
                          setState(() {
                            dish.matchedId = row[0].trim();
                            dish.matchedName = row[1].trim();
                            dish.score = 1.0; // manual pick counts as confident
                          });
                          Navigator.pop(context);
                        },
                      )),

                  const Divider(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        dish.matchedId = "";
                        dish.matchedName = "";
                        dish.score = 0.0;
                      });
                    },
                    child: const Text("Leave this slot empty"),
                  ),

                  const Divider(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        dish.matchedId = "";
                        dish.matchedName = "";
                        dish.score = 0.0;
                      });
                    },
                    child: const Text("Leave this slot empty"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add as new dish"),
                    onPressed: () async {
                      final newId = await showAddDishDialog(context);

                      if (newId != null && newId.isNotEmpty) {
                        final match = GoogleSheetsApi.foodItems.firstWhere(
                          (row) => row.isNotEmpty && row.first.trim() == newId,
                          orElse: () => [],
                        );

                        setState(() {
                          dish.matchedId = newId;
                          dish.matchedName = match.length > 1 ? match[1].trim() : dish.parsedName;
                          dish.score = 1.0;
                        });
                      }

                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> confirmAndSave() async {
    final Map<String, Map<int, String>> byDate = {};

    for (final m in matches) {
      byDate.putIfAbsent(m.dateString, () => {});
      byDate[m.dateString]![m.columnIndex] = m.matchedId ?? "";
    }

    final updates = byDate.entries
        .map((e) => CalendarDayUpdate(dateString: e.key, columnUpdates: e.value))
        .toList();

    await GoogleSheetsApi.applyPlanToCalendar(dayUpdates: updates);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diet plan saved to Google Sheets!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = groupedByDay.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text("Review Diet Plan Import")),
      body: ListView(
        children: days.map((day) {
          final dishes = groupedByDay[day]!;
          final reviewCount = dishes.where((d) => d.status == MatchStatus.needsReview).length;
          final notFoundCount = dishes.where((d) => d.status == MatchStatus.notFound).length;

          return ExpansionTile(
            title: Text("Day +$day  (${dishes.first.dateString})"),
            subtitle: Text(
              [
                if (reviewCount > 0) "check $reviewCount",
                if (notFoundCount > 0) "$notFoundCount not found",
                if (reviewCount == 0 && notFoundCount == 0) "all matched",
              ].join(" · "),
            ),
            children: dishes.map((dish) {
              return ListTile(
                leading: Icon(Icons.circle, color: dish.statusColor, size: 14),
                title: Text("${dish.mealLabel}: ${dish.parsedName}"),
                subtitle: Text(
                  dish.matchedId == null || dish.matchedId!.isEmpty
                      ? "No match found"
                      : "${dish.matchedName} (score ${dish.score.toStringAsFixed(2)})",
                ),
                onTap: () => openDishOptions(dish),
              );
            }).toList(),
          );
        }).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: confirmAndSave,
            child: const Text("Confirm & Save to Google Sheets"),
          ),
        ),
      ),
    );
  }
}