import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:menu_app/constants/api.dart' as api;
import 'package:menu_app/testingg/diet_import.dart';

class FoodOption {
  final String id;
  final String name;

  const FoodOption({
    required this.id,
    required this.name,
  });
}

class GoogleSheetsApi {
  static const credentials = api.gsheetsCredentials;
  static final spreadsheetId = api.spreadsheetId;
  static final gsheets = GSheets(credentials);
  static Worksheet? calendar;
  static Worksheet? foodList;
  static Worksheet? foodKeywords;
  static Worksheet? groceryList;

  static List<List<String>> calendarDates = [];
  static List<List<String>> foodItems = [];
  static Map<String, List<String>> keywordCategories = {};
  static List<List<String>> groceryItems = [];
  static bool loading = true;

  static Future<void> _writeQueue = Future.value();

  static Future init() async {
    final ss = await gsheets.spreadsheet(
      spreadsheetId,
      render: ValueRenderOption.formattedValue,
    );

    calendar = ss.worksheetByTitle("Calendar");
    foodList = ss.worksheetByTitle("FoodList");
    foodKeywords = ss.worksheetByTitle("FoodKeywords");
    groceryList = ss.worksheetByTitle("GroceryList");

    await Future.wait([loadCalendar(), loadFood(), loadFoodKeywords(), loadGroceryList()]);
  }

  // <------------------ CALL WHEN NEED TO REFRESH SPREADSHEET ------------------> //
  static Future refreshData() async {
    await Future.wait([loadCalendar(), loadFood(), loadFoodKeywords(), loadGroceryList()]);
  }
  // <------------------ CALL WHEN NEED TO REFRESH SPREADSHEET ------------------> //






  // <------------------ CALENDAR STUFF ------------------> //
  static Future loadCalendar() async {
    if (calendar == null) {
      calendarDates = [];
      loading = false;
      return;
    }

    final allRows = await calendar!.values.allRows();
    calendarDates = _cleanRows(allRows, expectedColumns: 15);
    loading = calendar != null && foodList != null ? false : loading;
  }

  // ADD FOOD ID TO SPECIFIC COLUMN IN CALENDAR SPREADSHEET
  static Future<void> updateSingleMealSlot({
    required int rowIndex,    // The row matching today's date
    required int columnIndex, // Exactly which of the 9 columns to target (3 through 11)
    required String foodId,   // The ID of the item just tapped (e.g., 'c01')
  }) async {
    try {
      await calendar!.values.insertValue(
        foodId.trim().toLowerCase(),
        column: columnIndex,
        row: rowIndex,
      );
      
      print('Successfully wrote $foodId directly to column $columnIndex');
    } catch (e) {
      print('Error writing to slot: $e');
    }
  }
  
  // Returns the number of days difference, or -1 if the ID was never found.
  static int calculateDaysSinceLastEaten({
    required String panelDate,
    required List<int> columnIndices, // 💎 CHANGED: Now takes a list of columns to scan
    required String foodId,
  }) {
    try {
      // 1. Locate the position index of the current panel in memory array
      int currentIdx = calendarDates.indexWhere((row) => row.isNotEmpty && row.first.trim() == panelDate);
      if (currentIdx == -1) return -1;

      DateTime currentDate = DateTime.parse(panelDate);
      String targetId = foodId.trim().toLowerCase();

      // 2. Loop backwards starting from the day right before this panel
      for (int i = currentIdx - 1; i >= 0; i--) {
        var row = calendarDates[i];
        if (row.isEmpty) continue;

        // 3. 💎 THE FIX: Check every column index associated with this food type on that historical day
        for (int colIndex in columnIndices) {
          // Shift from 1-based sheet column map to 0-based list item
          if ((colIndex - 1) < row.length) {
            String cellValue = row[colIndex - 1].trim().toLowerCase();

            // If found in ANY of the specified columns on this day, we found our most recent match!
            if (cellValue == targetId) {
              DateTime historicalDate = DateTime.parse(row.first.trim());
              return currentDate.difference(historicalDate).inDays;
            }
          }
        }
      }
    } catch (e) {
      print('Error calculating days since last eaten: $e');
    }
    return -1; // Never found in any tracking history
  }
  
  // AUTOFILL FEATURE 
  static void autofillDayLocal(String panelDate) {
    if (foodItems.isEmpty) return;

    final rowIndex = findRowIndexByDate(panelDate);
    if (rowIndex == -1) return;

    final random = Random();
    const allColumns = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

    // Helper: Checks prefix matching (e.g., 'c', 'v', 'nv')
    bool matchesPrefixes(String id, List<String> prefixes) {
      final lowerId = id.trim().toLowerCase();
      return prefixes.any((prefix) => lowerId.startsWith(prefix));
    }

    // Helper: Selects food filtering by ID Prefix + Required Meal Type ('b', 'l', 'd') + 3-Day History
    String selectFood({
      required List<String> allowedPrefixes,
      String? requiredMealType, // Pass 'b' for Breakfast slots
    }) {
      // 1. Filter food items by ID prefix AND Meal Type (row[4])
      final categoryPool = foodItems.where((row) {
        if (row.isEmpty) return false;

        final id = row[0].trim();
        final bool prefixMatches = matchesPrefixes(id, allowedPrefixes);

        // Check Meal Type column (row[4]) if specified
        bool mealTypeMatches = true;
        if (requiredMealType != null) {
          if (row.length <= 4) return false; // Row lacks Meal Type column
          final mealType = row[4].trim().toLowerCase();
          mealTypeMatches = mealType.contains(requiredMealType.toLowerCase());
        }

        return prefixMatches && mealTypeMatches;
      }).toList();

      if (categoryPool.isEmpty) return '';

      // 2. Apply 3-day recency filter
      final eligiblePool = categoryPool.where((row) {
        final id = row[0].trim().toLowerCase();
        final days = calculateDaysSinceLastEaten(
          panelDate: panelDate,
          columnIndices: allColumns,
          foodId: id,
        );
        return days == -1 || days >= 3;
      }).toList();

      // 3. Fallback to full B-tagged pool if recency leaves 0 choices
      final finalPool = eligiblePool.isNotEmpty ? eligiblePool : categoryPool;

      return finalPool[random.nextInt(finalPool.length)].first.trim().toLowerCase();
    }

    final targetRow = calendarDates[rowIndex - 2];

    // --- 1. Drink (Col 3) ---
    if (2 < targetRow.length) {
      targetRow[2] = selectFood(allowedPrefixes: ['d']);
    }

    // --- 2. Breakfast Mains (Cols 4, 5) -> Only 'v' / 'nv' tagged with 'B' ---
    for (final col in [4, 5]) {
      if ((col - 1) < targetRow.length) {
        targetRow[col - 1] = selectFood(
          allowedPrefixes: ['v', 'nv'],
          requiredMealType: 'b',
        );
      }
    }

    // --- 3. Breakfast Carb (Col 6) -> Only 'c' tagged with 'B' ---
    if (5 < targetRow.length) {
      targetRow[5] = selectFood(
        allowedPrefixes: ['c'],
        requiredMealType: 'b',
      );
    }

    // --- 4. Lunch Mains (Cols 8, 9) ---
    for (final col in [8, 9]) {
      if ((col - 1) < targetRow.length) {
        targetRow[col - 1] = selectFood(
          allowedPrefixes: ['v', 'nv'],
          requiredMealType: 'l',
        );
      }
    }

    // --- 5. Lunch Carb (Col 10) ---
    if (9 < targetRow.length) {
      targetRow[9] = selectFood(
        allowedPrefixes: ['c'],
        requiredMealType: 'l',
      );
    }

    // --- 6. Dinner Mains (Cols 12, 13) ---
    for (final col in [12, 13]) {
      if ((col - 1) < targetRow.length) {
        targetRow[col - 1] = selectFood(
          allowedPrefixes: ['v', 'nv'],
          requiredMealType: 'd',
        );
      }
    }

    // --- 7. Dinner Carb (Col 14) ---
    if (13 < targetRow.length) {
      targetRow[13] = selectFood(
        allowedPrefixes: ['c'],
        requiredMealType: 'd');
    }

    // --- 8. Leave Empty (Cols 7, 11, 15) ---
    for (final col in [7, 11, 15]) {
      if ((col - 1) < targetRow.length) {
        targetRow[col - 1] = '';
      }
    }
  }

  static Future<void> syncRowToSheet(String panelDate) async {
    final rowIndex = findRowIndexByDate(panelDate);
    if (rowIndex == -1) return;

    const columns = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    final row = calendarDates[rowIndex - 2];

    final writes = <Future<void>>[];
    for (final col in columns) {
      if ((col - 1) < row.length) {
        writes.add(updateSingleMealSlot(
          rowIndex: rowIndex,
          columnIndex: col,
          foodId: row[col - 1],
        ));
      }
    }

    await Future.wait(writes);
  }

  static bool dayHasExistingSelections(String panelDate) {
    final rowIndex = findRowIndexByDate(panelDate);
    if (rowIndex == -1) return false;

    final row = calendarDates[rowIndex - 2];
    const columns = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

    for (final col in columns) {
      if ((col - 1) < row.length && row[col - 1].trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }
  // AUTOFILL FEATURE 
  
  
  /// Updates local `calendarDates` matrix and pushes changes to Google Sheets
  static Future<void> applyPlanToCalendar({
    required List<CalendarDayUpdate> dayUpdates,
    Worksheet? targetWorksheet,
    List<List<String>>? targetDatesList,
  }) async {
    final ws = targetWorksheet ?? calendar;
    final dates = targetDatesList ?? calendarDates;

    if (ws == null) return;

    for (final update in dayUpdates) {
      // 1. Find row index in local dates array matching target date
      final rowIndex = dates.indexWhere(
        (row) => row.isNotEmpty && row.first.trim() == update.dateString,
      );

      if (rowIndex == -1) {
        debugPrint("⚠️ Date ${update.dateString} not found in calendar spreadsheet.");
        continue;
      }

      final targetRow = dates[rowIndex];

      // Ensure targetRow has at least 15 columns
      while (targetRow.length < 15) {
        targetRow.add("");
      }

      // 2. Apply column updates (Cols 4 through 15)
      update.columnUpdates.forEach((colIndex, foodId) {
        final arrayIndex = colIndex - 1;
        targetRow[arrayIndex] = foodId;
      });

      // 3. Update Google Sheets row
      // Array Index 0 corresponds to GSheets Row 2 (Row 1 is the header row)
      final gsheetsRowIndex = rowIndex + 2;
      
      // Writes columns 1 through 15 for that specific date row
      await ws.values.insertRow(gsheetsRowIndex, targetRow);
    }
  }
  // <------------------ CALENDAR STUFF ------------------> //






  // <------------------ MAIN FOOD LIST STUFF ------------------> //
  static Future loadFood() async {
    if (foodList == null) {
      foodItems = [];
      loading = false;
      return;
    }

    final allRows = await foodList!.values.allRows();
    foodItems = _cleanRows(allRows, expectedColumns: 5);
    loading = calendar != null && foodList != null ? false : loading;
  }

  // ADD NEW DISH TO SPREADSHEET
  static Future addFoodItem(List<String> id, String foodName, String ingredients) async {
    if (foodList == null) return;
    final String flatIds = id.join(', ');

    final newRow = [
      flatIds,
      foodName,
      ingredients,
    ];

    foodItems.add(newRow);
    await foodList!.values.appendRow(newRow);
  }
  
  // code for ingredient list
  static List<String> getSelectedFoodIdsForDate(String panelDate) {
    final rowIndex = calendarDates.indexWhere(
      (row) => row.isNotEmpty && row.first.trim() == panelDate,
    );
    if (rowIndex == -1) return [];

    final row = calendarDates[rowIndex];
    final List<String> ids = [];

    // Columns 3 through 15 hold every food slot for the day (drink + all 12 dish slots)
    for (int col = 3; col <= 15; col++) {
      if ((col - 1) < row.length) {
        final cell = row[col - 1].trim();
        if (cell.isNotEmpty) {
          ids.addAll(
            cell.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty),
          );
        }
      }
    }

    return ids;
  }

  static List<String> getIngredientsForDate(String panelDate) {
    final selectedIds = getSelectedFoodIdsForDate(panelDate);
    final Set<String> ingredients = {};

    for (final id in selectedIds) {
      final matchingRow = foodItems.firstWhere(
        (row) =>
            row.isNotEmpty &&
            row.first.toLowerCase().split(',').map((s) => s.trim()).contains(id),
        orElse: () => [],
      );

      if (matchingRow.length > 2 && matchingRow[2].trim().isNotEmpty) {
        final items = matchingRow[2]
            .split(',')
            .map((s) => s.trim().toLowerCase())
            .where((s) => s.isNotEmpty);
        ingredients.addAll(items);
      }
    }

    final sorted = ingredients.toList()..sort();
    return sorted;
  }

  static List<String> _idsForColumns(String panelDate, List<int> columns) {
    final rowIndex = calendarDates.indexWhere(
      (row) => row.isNotEmpty && row.first.trim() == panelDate,
    );
    if (rowIndex == -1) return [];

    final row = calendarDates[rowIndex];
    final List<String> ids = [];

    for (final col in columns) {
      if ((col - 1) < row.length) {
        final cell = row[col - 1].trim();
        if (cell.isNotEmpty) {
          ids.addAll(
            cell.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty),
          );
        }
      }
    }

    return ids;
  }

  static List<String> _ingredientsFromIds(List<String> ids) {
    final Set<String> ingredients = {};

    for (final id in ids) {
      final matchingRow = foodItems.firstWhere(
        (row) =>
            row.isNotEmpty &&
            row.first.toLowerCase().split(',').map((s) => s.trim()).contains(id),
        orElse: () => [],
      );

      if (matchingRow.length > 2 && matchingRow[2].trim().isNotEmpty) {
        final items = matchingRow[2]
            .split(',')
            .map((s) => s.trim().toLowerCase())
            .where((s) => s.isNotEmpty);
        ingredients.addAll(items);
      }
    }

    final sorted = ingredients.toList()..sort();
    return sorted;
  }

  static Map<String, List<String>> getCookPrepIngredients(String panelDate) {
    final today = DateTime.parse(panelDate);
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowDate = tomorrow.toIso8601String().split('T').first;

    const breakfastCols = [4, 5, 6, 7];
    const dinnerCols = [12, 13, 14, 15];
    const lunchCols = [8, 9, 10, 11];

    final breakfastIds = _idsForColumns(panelDate, breakfastCols);
    final dinnerIds = _idsForColumns(panelDate, dinnerCols);
    final tomorrowLunchIds = _idsForColumns(tomorrowDate, lunchCols);

    return {
      'Breakfast': _ingredientsFromIds(breakfastIds),
      'Dinner': _ingredientsFromIds(dinnerIds),
      "Tomorrow's Lunch": _ingredientsFromIds(tomorrowLunchIds),
    };
  }
  
  // <------------------ MAIN FOOD LIST STUFF ------------------> //






  // <------------------ KEYWORDS ------------------> //
  static Future loadFoodKeywords() async {
    if (foodKeywords == null) {
      keywordCategories = {};
      return;
    }

    final allRows = await foodKeywords!.values.allRows();
    if (allRows.length <= 1) {
      keywordCategories = {};
      return;
    }

    final headers = allRows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final dataRows = allRows.sublist(1);

    const columnPrefixes = {
      'non veg': 'nv',
      'carb': 'c',
      'drinks': 'd',
      'sweets': 's',
      'fruit': 'f',
    };

    final Map<String, List<String>> result = {};

    columnPrefixes.forEach((columnName, prefix) {
      final colIndex = headers.indexOf(columnName);
      if (colIndex == -1) {
        result[prefix] = [];
        return;
      }
      result[prefix] = dataRows
          .where((row) => colIndex < row.length)
          .map((row) => row[colIndex].toString().trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList();
    });

    keywordCategories = result;
  }
  // <------------------ KEYWORDS ------------------> //






  // <------------------ GROCERY LIST STUFF ------------------> //
  static Future loadGroceryList() async {
    if (groceryList == null) {
      groceryItems = [];
      loading = false;
      return;
    }

    final allRows = await groceryList!.values.allRows();
    groceryItems = _cleanRows(allRows, expectedColumns: 2);
    loading = calendar != null && groceryList != null ? false : loading;
  }

  static Future<void> toggleGroceryItemStatus(int index, String newStatus) async {
    if (groceryList == null || index >= groceryItems.length) return;

    try {
      // Row 1 is header, so item at index 0 maps to Row 2 in Google Sheets
      await groceryList!.values.insertValue(
        newStatus,
        column: 2,
        row: index + 2,
      );
    } catch (e) {
      debugPrint("Error writing status to Google Sheets: $e");
    }
  }

  static Future<void> addGroceryItem(String ingredient) async {
    final cleanItem = ingredient.trim();
    if (cleanItem.isEmpty) return;

    final newRow = [cleanItem, 'n'];

    // 1. Instantly update local memory
    groceryItems.add(newRow);

    // 3. Queue the GSheets network request so fast taps run sequentially in order
    _writeQueue = _writeQueue.then((_) async {
      if (groceryList == null) return;
      try {
        await groceryList!.values.appendRow(newRow);
      } catch (e) {
        debugPrint("Error adding item to Google Sheets: $e");
      }
    });
  }

  static Future<void> clearGroceryList() async {
    if (groceryList == null) return;

    // 1. Wipe local memory immediately
    groceryItems.clear();

    try {
      // 2. Clear all cells in the sheet
      await groceryList!.clear();

      // 3. Re-insert column headers for future additions
      await groceryList!.values.insertRow(1, ['Item', 'bought?']);
    } catch (e) {
      debugPrint("Error clearing Google Sheet: $e");
    }
  }
  // <------------------ GROCERY LIST STUFF ------------------> //






  static List<List<String>> _cleanRows(
    List<List<dynamic>> rawRows, {
    required int expectedColumns,
  }) {
    if (rawRows.length <= 1) {
      return [];
    }

    return rawRows
        .sublist(1)
        .where((row) {
          if (row.isEmpty) return false;
          final firstValue = row.first;
          return firstValue != null && firstValue.toString().trim().isNotEmpty;
        })
        .map((row) {
          final paddedRow = List<String>.filled(expectedColumns, "");
          for (int i = 0; i < row.length && i < expectedColumns; i++) {
            final value = row[i];
            paddedRow[i] = value == null ? "" : value.toString();
          }
          return paddedRow;
        })
        .toList();
  }

  static List<String> getFoodNames() {
    return getFoodOptionsByPrefix([]).map((option) => option.name).toList();
  }

  static List<FoodOption> getFoodOptionsByPrefix(List<String> prefixes) {
    // 1. Clean up the whole list of prefixes upfront
    final normalizedPrefixes = prefixes
        .map((p) => p.trim().toLowerCase())
        .where((p) => p.isNotEmpty) // Remove any accidentally empty strings
        .toList();

    final options = foodItems
      .where((row) {
        if (row.isEmpty) return false;
        
        // Grab the raw cell string: e.g., "nv03, c05"
        final rawIdCell = row.first.trim().toLowerCase();
        if (rawIdCell.isEmpty) return false;

        // If no prefixes are requested, let everything through
        if (normalizedPrefixes.isEmpty) return true;

        // 💎 THE FIX: Split the cell by commas to handle multiple IDs
        // "nv03, c05" becomes a list: ['nv03', 'c05'] (with spaces trimmed)
        final List<String> individualIds = rawIdCell
            .split(',')
            .map((id) => id.trim())
            .toList();

        // 💎 THE NEW CHECK: Check if ANY individual ID starts with ANY requested prefix
        // For ['nv03', 'c05'], it checks if either starts with 'c'. 'c05' matches!
        return individualIds.any((id) {
          return normalizedPrefixes.any((prefix) => id.startsWith(prefix));
        });
      })
      .map((row) {
        final id = row.isNotEmpty ? row.first.trim() : '';
        // Assuming your standard layout is: index 0 = ID, index 1 = Name, index 2 = Category
        // Double check if your food name is at index 1 or index 2 in your GSheets table!
        final name = row.length > 1 ? row[1].trim() : ''; 
        
        return FoodOption(
          id: id,
          name: name.isNotEmpty ? name : 'Unnamed item',
        );
      })
      .toList();

    options.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return options;
  }

  static int findRowIndexByDate(String panelDate) {
    for (int i = 0; i < calendarDates.length; i++) {
      var row = calendarDates[i];
      if (row.isNotEmpty) {
        String sheetDate = row.first.trim(); // Reads Column 1 (Date Column)
        
        // Matches the 'YYYY-MM-DD' format passed down by your DayList widget
        if (sheetDate == panelDate) {
          // 💎 FIX: Return i + 2 to offset for BOTH 0-indexing and the skipped Header Row!
          return i + 2; 
        }
      }
    }
    return -1; // Returns -1 if the date doesn't exist in your spreadsheet yet
  }

  

  

  
} 






