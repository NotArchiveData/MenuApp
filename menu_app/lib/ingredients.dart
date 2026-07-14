import 'package:flutter/material.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/gsheets_api.dart';

Future<void> showIngredientsDialog(BuildContext context, String panelDate) async {
  final ingredients = GoogleSheetsApi.getIngredientsForDate(panelDate);

  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 25),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 410),
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
                  child: ingredients.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No ingredients yet', style: TextStyle(color: Colors.white70)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: ingredients.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            return Text(
                              ingredients[i],
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            );
                          },
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