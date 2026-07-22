import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/gsheets_api.dart';

class GroceryListPage extends StatefulWidget {
  const GroceryListPage({super.key});

  @override
  State<GroceryListPage> createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // Custom Header with Back & Delete Buttons
              topBar(context),

              const SizedBox(height: 20),

              // Grocery List Content
              groceryListContent(),

              addButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // go back
            IconButton(
              onPressed: () => Navigator.pop(context), 
              icon: Icon(Icons.arrow_back_ios_new, color: blackText, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
           
            Text(
              "Grocery List",
              style: TextStyle(
                color: text,
                fontSize: primaryText,
                fontWeight: FontWeight.w600,
                ),
              textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
            ),
          ],
        ),

        // icon to delete items
        Material(
          color: presentBg,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              // 1. Instantly clear local list & trigger UI rebuild to show empty state
              setState(() {
                GoogleSheetsApi.groceryItems.clear();
              });

              // 2. Clear Google Sheet in the background
              await GoogleSheetsApi.clearGroceryList();
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              // child: Icon(Icons.exit_to_app, color: Colors.white),
              child: Icon(Icons.delete_forever, color: Colors.white70)
            ),
          ),
        ),
      ],
    );
  }

  Widget groceryListContent() {
    final items = GoogleSheetsApi.groceryItems;

    return Expanded(
      child: items.isEmpty
          ? const Center(
              child: Text(
                "Your grocery list is empty",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(rounding),
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final itemName = items[index][0];
                  final bool isBought = items[index].length > 1 &&
                      items[index][1].trim().toLowerCase() == 'y';

                  final Color fadedBlack = Colors.black.withValues(alpha: 0.25);
                  final Color containerBg = isBought
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5);
                  final Color textColor = isBought
                      ? blackText.withValues(alpha: 0.35)
                      : blackText;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: containerBg,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        HapticFeedback.lightImpact();

                        final currentStatus = (items[index].length > 1)
                            ? items[index][1].trim().toLowerCase()
                            : 'n';
                        final newStatus = (currentStatus == 'y') ? 'n' : 'y';

                        setState(() {
                          items[index] = [items[index][0], newStatus];
                        });

                        await GoogleSheetsApi.toggleGroceryItemStatus(index, newStatus);
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: tertiaryText,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isBought ? fadedBlack : Colors.transparent,
                              border: Border.all(
                                color: isBought ? fadedBlack : Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget addButton() {
    return Material(
      color: presentBg,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();

          const newItemName = "Sample Item";

          // Trigger page setState so the new item renders immediately
          setState(() {
            GoogleSheetsApi.addGroceryItem(newItemName);
          });
        },
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(14.0),
          child: Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }

}