import 'package:flutter/material.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/gsheets_api.dart';

class GroceryListPage extends StatelessWidget {
  const GroceryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = GoogleSheetsApi.groceryItems;
    
    return Scaffold(
      backgroundColor: mainBg, // Replace with your mainBg variable
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header with Back Button
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context), // Handled explicitly
                    icon: Icon(Icons.arrow_back_ios_new, color: blackText, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Grocery List",
                    style: TextStyle(
                      color: blackText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Grocery List Content
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          "Your grocery list is empty",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          // Extract the string from column 0
                          final itemName = items[index][0];

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, 
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.fiber_manual_record,
                                  size: 8,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    itemName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}