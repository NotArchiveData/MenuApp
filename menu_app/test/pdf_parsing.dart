// import 'dart:convert';
// import 'dart:developer';

// /// Represents a single day's meals organized by item lists
// class DayMeals {
//   final int dayOffset; // 1 = Day+1, 2 = Day+2, etc.
//   final List<String> breakfast;
//   final List<String> lunch;
//   final List<String> dinner;

//   DayMeals({
//     required this.dayOffset,
//     required this.breakfast,
//     required this.lunch,
//     required this.dinner,
//   });

//   @override
//   String toString() {
//     return 'Day $dayOffset -> Breakfast: $breakfast | Lunch: $lunch | Dinner: $dinner';
//   }
// }

// /// Represents the entire parsed week plan
// class WeeklyDietPlan {
//   final Map<int, DayMeals> dailyPlans; // Key is Day Offset (1..7)

//   WeeklyDietPlan({required this.dailyPlans});

//   factory WeeklyDietPlan.fromJsonString(String jsonRaw) {
//     final Map<String, dynamic> decoded = jsonDecode(jsonRaw);

//     final Map<String, dynamic> breakfastMap = decoded['breakfast'] ?? {};
//     final Map<String, dynamic> lunchMap = decoded['lunch'] ?? {};
//     final Map<String, dynamic> dinnerMap = decoded['dinner'] ?? {};

//     final Map<int, DayMeals> plans = {};

//     // Collect all unique day offsets across breakfast, lunch, dinner (usually 1..7)
//     final allKeys = <String>{
//       ...breakfastMap.keys,
//       ...lunchMap.keys,
//       ...dinnerMap.keys,
//     };

//     for (final keyStr in allKeys) {
//       final int? dayOffset = int.tryParse(keyStr);
//       if (dayOffset == null) continue;

//       final List<String> bList = List<String>.from(breakfastMap[keyStr] ?? []);
//       final List<String> lList = List<String>.from(lunchMap[keyStr] ?? []);
//       final List<String> dList = List<String>.from(dinnerMap[keyStr] ?? []);

//       plans[dayOffset] = DayMeals(
//         dayOffset: dayOffset,
//         breakfast: bList,
//         lunch: lList,
//         dinner: dList,
//       );
//     }

//     return WeeklyDietPlan(dailyPlans: plans);
//   }

//   static void testStepOne() {
//     final String mockAnswer = '''{"breakfast":{"1":["egg omelette","veggies","green chutney"],"2":["sourdough toast"],"3":["ragi","oats","rice flour","egg"],"4":["kacha kela","peanut butter toast"],"5":["peanut","corn","veggies salad"],"6":["ragi pancake"]},"lunch":{"1":["rice","palak paneer","salad"],"2":["quinoa veggies pulao","amaranth saag"],"3":["rice","mutton curry","mix salad"],"4":["rice","tori sabzi","paneer","salad"],"5":["rice","soya matter sabzi","salad"],"6":["rice","quinoa","fish","bhindi sabzi","salad"],"7":["curd rice","lauki sabzi"]},"dinner":{"1":["ragi roti","mix veg","salad"],"2":["veggies","khichdi"],"3":["chicken","corn veggies salad"],"4":["mushroom beans carrot","fish","ragi roti"],"5":["ragi","paneer capsicum sabzi","salad"],"6":["mix veg chila","pumpkin sabzi","pumpkin tomato soup","egg bhurji"],"7":["brocolli and tofu tikki","green chutney"]}}''';

//     final dietPlan = WeeklyDietPlan.fromJsonString(mockAnswer);

//     print("=== STEP 1 PARSING VERIFICATION ===");
//     dietPlan.dailyPlans.forEach((day, meals) {
//       print("DAY +$day:");
//       print("  Breakfast (Cols 4-7) : ${meals.breakfast}");
//       print("  Lunch     (Cols 8-11): ${meals.lunch}");
//       print("  Dinner    (Cols 12-15): ${meals.dinner}");
//     });
//   }

//   static void testStepTwo() {
//     final List<List<String>> mockFoodItems = [
//       ["c01", "sourdough bread", "flour, water, salt"],
//       ["c02", "quinoa (plain)", "quinoa"],
//       ["c03", "quinoa veggies pulao", "quinoa, carrots, peas"],
//       ["c04", "egg omelette", "eggs, spices"],
//       ["c05", "palak paneer", "spinach, cottage cheese"],
//       ["c06", "green chutney", "coriander, mint, chili"],
//       ["c07", "boiled rice", "rice"],
//       ["c08", "ragi roti", "ragi flour"],
//     ];

//     final parsedSample = [
//       "egg omelette",
//       "sourdough toast",
//       "quinoa with veggies",
//       "quinoa",
//       "palak paneer",
//       "green chutney",
//       "ragi roti"
//     ];

//     print("=== STEP 2 LOCAL MATCHING VERIFICATION ===");
//     for (final dish in parsedSample) {
//       final matchedId = LocalFoodMatcher.findBestMatchId(dish, mockFoodItems);
//       print("Parsed Name: '${dish.padRight(22)}' -> Matched ID: ${matchedId ?? 'NOT FOUND'}");
//     }
//   }

//   static void testStepThree() {
//     final List<List<String>> mockFoodItems = [
//       ["c01", "sourdough bread"],
//       ["c02", "quinoa (plain)"],
//       ["c03", "quinoa veggies pulao"],
//       ["c04", "egg omelette"],
//       ["c05", "palak paneer"],
//       ["c06", "green chutney"],
//       ["c07", "boiled rice"],
//       ["c08", "ragi roti"],
//       ["c09", "mix veg"],
//       ["c10", "salad"],
//       ["c11", "mutton curry"],
//     ];

//     final String mockAnswer = '''{
//       "breakfast": {
//         "1": ["egg omelette", "green chutney"],
//         "2": ["sourdough toast"]
//       },
//       "lunch": {
//         "1": ["boiled rice", "palak paneer", "salad"],
//         "2": ["quinoa veggies pulao"]
//       },
//       "dinner": {
//         "1": ["ragi roti", "mix veg", "salad"]
//       }
//     }''';

//     final dietPlan = WeeklyDietPlan.fromJsonString(mockAnswer);

//     final updates = DietPlanMapper.buildCalendarUpdates(
//       plan: dietPlan,
//       foodItems: mockFoodItems,
//     );

//     print("=== STEP 3 CALENDAR MATRIX VERIFICATION ===");
//     for (final dayUpdate in updates) {
//       print("\nDATE: ${dayUpdate.dateString}");
//       print("  Breakfast (Cols 4-7)  : ${[4, 5, 6, 7].map((c) => dayUpdate.columnUpdates[c]).toList()}");
//       print("  Lunch     (Cols 8-11) : ${[8, 9, 10, 11].map((c) => dayUpdate.columnUpdates[c]).toList()}");
//       print("  Dinner    (Cols 12-15): ${[12, 13, 14, 15].map((c) => dayUpdate.columnUpdates[c]).toList()}");
//     }
//   }
// }

// class LocalFoodMatcher {
//   static String? findBestMatchId(
//     String parsedName,
//     List<List<String>> foodItems, {
//     double minThreshold = 0.35,
//   }) {
//     if (foodItems.isEmpty || parsedName.trim().isEmpty) return null;

//     final targetClean = _normalize(parsedName);
//     if (targetClean.isEmpty) return null;

//     String? bestMatchId;
//     double highestScore = 0.0;

//     for (final row in foodItems) {
//       if (row.length < 2) continue;

//       final String id = row[0].trim();
//       final String dbName = row[1].trim();

//       final dbNameClean = _normalize(dbName);
//       if (dbNameClean.isEmpty) continue;

//       if (targetClean == dbNameClean) {
//         return id;
//       }

//       final double score = _calculateSimilarity(targetClean, dbNameClean);

//       if (score > highestScore) {
//         highestScore = score;
//         bestMatchId = id;
//       }
//     }

//     if (highestScore >= minThreshold) {
//       return bestMatchId;
//     }

//     return null;
//   }

//   static String _normalize(String input) {
//     return input
//         .toLowerCase()
//         .replaceAll(RegExp(r'\((.*?)\)'), '')
//         .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
//         .replaceAll(RegExp(r'\s+'), ' ')
//         .trim();
//   }

//   static double _calculateSimilarity(String target, String candidate) {
//     final targetTokens = target.split(' ').where((t) => t.isNotEmpty).toSet();
//     final candidateTokens = candidate.split(' ').where((t) => t.isNotEmpty).toSet();

//     if (targetTokens.isEmpty || candidateTokens.isEmpty) return 0.0;

//     final intersection = targetTokens.intersection(candidateTokens).length;
//     final union = targetTokens.union(candidateTokens).length;
//     final double jaccardScore = intersection / union;

//     double substringBonus = 0.0;
//     for (final t in targetTokens) {
//       if (candidate.contains(t) && t.length > 3) {
//         substringBonus += 0.25;
//       }
//     }

//     final int distance = _levenshteinDistance(target, candidate);
//     final int maxLen = target.length > candidate.length ? target.length : candidate.length;
//     final double levenshteinScore = maxLen == 0 ? 1.0 : (1.0 - (distance / maxLen));

//     return (jaccardScore * 0.5) + (substringBonus * 0.25) + (levenshteinScore * 0.25);
//   }

//   static int _levenshteinDistance(String s1, String s2) {
//     if (s1 == s2) return 0;
//     if (s1.isEmpty) return s2.length;
//     if (s2.isEmpty) return s1.length;

//     List<int> v0 = List<int>.filled(s2.length + 1, 0);
//     List<int> v1 = List<int>.filled(s2.length + 1, 0);

//     for (int i = 0; i <= s2.length; i++) {
//       v0[i] = i;
//     }

//     for (int i = 0; i < s1.length; i++) {
//       v1[0] = i + 1;
//       for (int j = 0; j < s2.length; j++) {
//         final cost = (s1[i] == s2[j]) ? 0 : 1;
//         v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
//       }
//       for (int j = 0; j <= s2.length; j++) {
//         v0[j] = v1[j];
//       }
//     }
//     return v1[s2.length];
//   }
// }

// /// Holds the mapped ID payload for a specific calendar date row
// class CalendarDayUpdate {
//   final String dateString;
//   final Map<int, String> columnUpdates;

//   CalendarDayUpdate({
//     required this.dateString,
//     required this.columnUpdates,
//   });

//   @override
//   String toString() {
//     return 'Date: $dateString | Column Updates: $columnUpdates';
//   }
// }

// class DietPlanMapper {
//   static List<CalendarDayUpdate> buildCalendarUpdates({
//     required WeeklyDietPlan plan,
//     required List<List<String>> foodItems,
//     DateTime? startDate,
//   }) {
//     final baseDate = startDate ?? DateTime.now();
//     final List<CalendarDayUpdate> updates = [];

//     const breakfastCols = [4, 5, 6, 7];
//     const lunchCols = [8, 9, 10, 11];
//     const dinnerCols = [12, 13, 14, 15];

//     plan.dailyPlans.forEach((dayOffset, dayMeals) {
//       final targetDateTime = baseDate.add(Duration(days: dayOffset));
//       final dateString = targetDateTime.toIso8601String().split('T').first;

//       final Map<int, String> colMap = {};

//       void mapMealToColumns(List<String> foodNames, List<int> targetCols) {
//         for (int i = 0; i < targetCols.length; i++) {
//           final int colNum = targetCols[i];
//           if (i < foodNames.length) {
//             final name = foodNames[i];
//             final matchedId = LocalFoodMatcher.findBestMatchId(name, foodItems);

//             if (matchedId != null) {
//               colMap[colNum] = matchedId;
//             } else {
//               log("⚠️ Unmatched dish on $dateString (Col $colNum): '$name'");
//               colMap[colNum] = "";
//             }
//           } else {
//             colMap[colNum] = "";
//           }
//         }
//       }

//       mapMealToColumns(dayMeals.breakfast, breakfastCols);
//       mapMealToColumns(dayMeals.lunch, lunchCols);
//       mapMealToColumns(dayMeals.dinner, dinnerCols);

//       updates.add(CalendarDayUpdate(
//         dateString: dateString,
//         columnUpdates: colMap,
//       ));
//     });

//     return updates;
//   }
// }