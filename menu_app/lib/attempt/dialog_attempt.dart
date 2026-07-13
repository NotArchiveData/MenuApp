import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/add_dish.dart';

class SimpleFoodDialog extends StatefulWidget {
  const SimpleFoodDialog({super.key});

  @override
  State<SimpleFoodDialog> createState() => _SimpleFoodDialogState();
}

class _SimpleFoodDialogState extends State<SimpleFoodDialog> {
  final TextEditingController searchController = TextEditingController();

  int selectedTabIndex = 0;

  static const List<String> tabIcons = [
    "assets/icons/everything.svg",
    "assets/icons/carb.svg",
    "assets/icons/nonveg.svg",
    "assets/icons/veg.svg",
    "assets/icons/fruit.svg",
    "assets/icons/dessert.svg",
    "assets/icons/drink.svg",
  ];

  static const List<String> tabLabels = [
    "All Dishes",
    "Carb",
    "Non-Veg",
    "Veg",
    "Fruit",
    "Dessert",
    "Drink",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 400,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 4, child: searchPanel()),
            const SizedBox(width: 12),
            Column(
              children: [
                Expanded(child: iconTabsPanel()),
                const SizedBox(height: 12),
                SizedBox(width: 50, height: 50, child: addButtonPanel()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pastBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(tabLabels[selectedTabIndex]),
          SizedBox(
            height: 42,
            child: TextField(
              cursorHeight: 20,
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search..',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: tertiaryText),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconTabsPanel() {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: pastBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(tabIcons.length, (i) => tabIcon(i)),
      ),
    );
  }

  Widget tabIcon(int index) {
    final bool isSelected = selectedTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => selectedTabIndex = index),
      child: SizedBox(
        width: 50,
        height: 40,
        child: Center(
          child: SvgPicture.asset(
            tabIcons[index],
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white70 : Colors.white38,
              BlendMode.srcIn,
            ),
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }

  Widget addButtonPanel() {
    return Container(
      decoration: BoxDecoration(
        color: pastBg,
        borderRadius: BorderRadius.circular(200),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            await showAddDishDialog(context);
            setState(() {});
          },
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.add, color: Colors.white60),
          ),
        ),
      ),
    );
  }
}