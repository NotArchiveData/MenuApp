import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:menu_app/gsheets_api.dart';
import 'package:menu_app/testingg/diet_review.dart';
import 'package:menu_app/testingg/loadingoverlay.dart';

// ============================================================
// MOCK DATA — swap the button's call target once real Gemini
// output is ready to test instead of this fixed sample.
// ============================================================
const String mockDietPlanJson = '''{"breakfast":{"1":["YOUR MOM MUAHAHAHA","green chutney"],"2":["sourdough toast","dhania chutney","boiled aloo slice","guacamole","sprinkled mix seeds"],"3":["ragi oats dosa","boiled egg"],"4":["stir fry kacha kela","peanut butter","toast"],"5":["boiled peanut corn veggies salad","sweet potato"],"6":["ragi oats pancake","honey","fruit"]},"lunch":{"1":["boiled rice","palak paneer","salad"],"2":["quinoa veggies pulao","amaranth saag"],"3":["boiled rice","mutton curry","mix salad"],"4":["boiled rice","tori sabzi","stir fry paneer","salad"],"5":["boiled rice","soya matar sabzi","salad"],"6":["boiled rice or quinoa","pan fry fish","bhindi sabzi","salad"],"7":["curd rice","lauki sabzi"]},"dinner":{"1":["ragi roti","mix veg","salad"],"2":["boiled veggies","khichdi"],"3":["grilled chicken","corn veggies salad"],"4":["stir fry mushroom beans carrot","fish","ragi roti"],"5":["ragi roti","paneer capsicum sabzi","salad"],"6":["mix veg chila","pumpkin sabzi or soup","egg bhurji"],"7":["broccoli tofu tikki","green chutney"]}}''';

// ============================================================
// PARSING: turns Gemini's JSON into a structured week
// ============================================================

class DayMeals {
  final int dayOffset; // 1 = tomorrow, 2 = day after, etc.
  final List<String> breakfast;
  final List<String> lunch;
  final List<String> dinner;

  DayMeals({
    required this.dayOffset,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}

class WeeklyDietPlan {
  final Map<int, DayMeals> dailyPlans;

  WeeklyDietPlan({required this.dailyPlans});

  factory WeeklyDietPlan.fromJsonString(String jsonRaw) {
    final Map<String, dynamic> decoded = jsonDecode(jsonRaw);

    final Map<String, dynamic> breakfastMap = decoded['breakfast'] ?? {};
    final Map<String, dynamic> lunchMap = decoded['lunch'] ?? {};
    final Map<String, dynamic> dinnerMap = decoded['dinner'] ?? {};

    final Map<int, DayMeals> plans = {};

    final allKeys = <String>{
      ...breakfastMap.keys,
      ...lunchMap.keys,
      ...dinnerMap.keys,
    };

    for (final keyStr in allKeys) {
      final int? dayOffset = int.tryParse(keyStr);
      if (dayOffset == null) continue;

      plans[dayOffset] = DayMeals(
        dayOffset: dayOffset,
        breakfast: List<String>.from(breakfastMap[keyStr] ?? []),
        lunch: List<String>.from(lunchMap[keyStr] ?? []),
        dinner: List<String>.from(dinnerMap[keyStr] ?? []),
      );
    }

    return WeeklyDietPlan(dailyPlans: plans);
  }
}

// ============================================================
// MATCHING: finds the closest FoodList entry for a parsed name
// ============================================================

class FoodMatcher {
  // Prints the top 3 closest candidates every time, regardless of
  // whether a match was accepted — this is what lets you see WHY
  // something like "potato salad" picked (or missed) "salad".
  static String? findBestMatchId(
    String parsedName,
    List<List<String>> foodItems, {
    double minThreshold = 0.35,
  }) {
    if (foodItems.isEmpty || parsedName.trim().isEmpty) return null;

    final targetClean = normalizeText(parsedName);
    if (targetClean.isEmpty) return null;

    final List<MapEntry<List<String>, double>> scored = [];

    for (final row in foodItems) {
      if (row.length < 2) continue;
      final dbNameClean = normalizeText(row[1].trim());
      if (dbNameClean.isEmpty) continue;

      final score = targetClean == dbNameClean
          ? 1.0
          : calculateSimilarity(targetClean, dbNameClean);

      scored.add(MapEntry(row, score));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    final top3 = scored
        .take(3)
        .map((e) => "${e.key[1]} (${e.value.toStringAsFixed(2)})")
        .join(", ");
    print("    candidates for '$parsedName': $top3");

    if (scored.isEmpty) {
      print("    -> NOT FOUND (food list empty or no valid names)");
      return null;
    }

    final best = scored.first;
    if (best.value >= minThreshold) {
      print("    -> MATCHED '${best.key[1]}' (id: ${best.key[0]}, score: ${best.value.toStringAsFixed(2)})");
      return best.key[0].trim();
    }

    print("    -> NOT FOUND (best score ${best.value.toStringAsFixed(2)} below threshold $minThreshold)");
    return null;
  }

  static String normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'\((.*?)\)'), '')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static double calculateSimilarity(String target, String candidate) {
    final targetTokens = target.split(' ').where((t) => t.isNotEmpty).toSet();
    final candidateTokens = candidate.split(' ').where((t) => t.isNotEmpty).toSet();

    if (targetTokens.isEmpty || candidateTokens.isEmpty) return 0.0;

    final intersection = targetTokens.intersection(candidateTokens).length;
    final union = targetTokens.union(candidateTokens).length;
    final jaccardScore = intersection / union;

    double substringBonus = 0.0;
    for (final t in targetTokens) {
      if (candidate.contains(t) && t.length > 3) {
        substringBonus += 0.25;
      }
    }

    final distance = levenshteinDistance(target, candidate);
    final maxLen = target.length > candidate.length ? target.length : candidate.length;
    final levenshteinScore = maxLen == 0 ? 1.0 : (1.0 - (distance / maxLen));

    return (jaccardScore * 0.5) + (substringBonus * 0.25) + (levenshteinScore * 0.25);
  }

  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        final cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[s2.length];
  }
}

// ============================================================
// MAPPING: matched ids -> calendar column updates per date
// ============================================================

class CalendarDayUpdate {
  final String dateString;
  final Map<int, String> columnUpdates;

  CalendarDayUpdate({required this.dateString, required this.columnUpdates});
}

class DietPlanMapper {
  static List<CalendarDayUpdate> buildCalendarUpdates({
    required WeeklyDietPlan plan,
    required List<List<String>> foodItems,
    DateTime? startDate,
  }) {
    final baseDate = startDate ?? DateTime.now();
    final List<CalendarDayUpdate> updates = [];

    const breakfastCols = [4, 5, 6, 7];
    const lunchCols = [8, 9, 10, 11];
    const dinnerCols = [12, 13, 14, 15];

    plan.dailyPlans.forEach((dayOffset, dayMeals) {
      final targetDateTime = baseDate.add(Duration(days: dayOffset));
      final dateString = targetDateTime.toIso8601String().split('T').first;

      print("\n[$dateString] (Day +$dayOffset)");

      final Map<int, String> colMap = {};

      void mapMealToColumns(List<String> foodNames, List<int> targetCols, String mealLabel) {
        for (int i = 0; i < targetCols.length; i++) {
          final colNum = targetCols[i];
          if (i < foodNames.length) {
            final name = foodNames[i];
            print("  $mealLabel slot $colNum: '$name'");
            final matchedId = FoodMatcher.findBestMatchId(name, foodItems);
            colMap[colNum] = matchedId ?? "";
          } else {
            colMap[colNum] = "";
          }
        }
      }

      mapMealToColumns(dayMeals.breakfast, breakfastCols, "Breakfast");
      mapMealToColumns(dayMeals.lunch, lunchCols, "Lunch");
      mapMealToColumns(dayMeals.dinner, dinnerCols, "Dinner");

      updates.add(CalendarDayUpdate(dateString: dateString, columnUpdates: colMap));
    });

    return updates;
  }
}

// ============================================================
// ORCHESTRATION: the single entry point the button calls
// ============================================================

Future<void> importDietPlanFromJson(
  BuildContext context,
  String rawJson, {
  DateTime? startDate,
}) async {
  try {
    final dietPlan = WeeklyDietPlan.fromJsonString(rawJson);

    final matches = buildDishMatches(
      plan: dietPlan,
      foodItems: GoogleSheetsApi.foodItems,
      startDate: startDate,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DietReviewPage(matches: matches)),
      );
    }
  } catch (e) {
    print("Error preparing diet plan review: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Import failed: $e")),
      );
    }
  }

}