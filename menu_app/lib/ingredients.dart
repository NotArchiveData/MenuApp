import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/gsheets_api.dart';

Future<void> showIngredientsDialog(BuildContext context, String panelDate) async {
  final grouped = GoogleSheetsApi.getCookPrepIngredients(panelDate);

  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2b2b2b),
              border: Border.all(color: accent),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Ingredients",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: grouped.entries
                        .map((entry) => _ingredientSection(entry.key, entry.value))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _ingredientSection(String title, List<String> ingredients) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (ingredients.isEmpty)
          const Text('Nothing yet', style: TextStyle(color: Colors.white38, fontSize: 14))
        else
          ...ingredients.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  GoogleSheetsApi.addGroceryItem(item);
                },
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}