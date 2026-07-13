import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/day/add_dish.dart';
import 'package:menu_app/gsheets_api.dart';

class FoodSelectionDialog extends StatefulWidget {
  const FoodSelectionDialog({
    super.key,
    required this.panelDate,
    required this.columnNumberToAddFood,
    required this.prefix,
  });

  final String panelDate;
  final int columnNumberToAddFood;
  final List<String> prefix;

  @override
  State<FoodSelectionDialog> createState() => _FoodSelectionDialogState();
}

class _FoodSelectionDialogState extends State<FoodSelectionDialog> {
  int selectedTabIndex = 0;
  final TextEditingController searchController = TextEditingController();

  // index 0 = All (bottom-right), rest are top-row categories
  final List<Map<String, String>> tabs = const [
    {'icon': 'all', 'prefix': ''},
    {'icon': 'c', 'prefix': 'c'},
    {'icon': 'nv', 'prefix': 'nv'},
    {'icon': 'd', 'prefix': 'd'},
    {'icon': 's', 'prefix': 's'},
    {'icon': 'f', 'prefix': 'f'},
  ];

  IconData _iconForIndex(int i) {
    switch (i) {
      case 0:
        return Icons.all_inclusive;
      case 1:
        return Icons.rice_bowl;
      case 2:
        return Icons.kebab_dining;
      case 3:
        return Icons.local_drink;
      case 4:
        return Icons.cake;
      default:
        return Icons.apple;
    }
  }

  List<int> getColumnIndices() {
    if (widget.prefix.contains('c')) return [6, 10, 14];
    if (widget.prefix.contains('d')) return [3];
    return [4, 5, 7, 8, 9, 11, 12, 13, 15];
  }

  String getTitle() => widget.prefix.contains('c') ? 'Carb' : widget.prefix.contains('d') ? 'Drink' : 'Dish';

  List<FoodOption> _masterOptions() => GoogleSheetsApi.getFoodOptionsByPrefix(widget.prefix);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _tabButton(int i) {
    final bool isSelected = selectedTabIndex == i;
    final color = isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3);
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => selectedTabIndex = i);
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border(bottom: BorderSide(color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.16), width: 1.6)),
          ),
          alignment: Alignment.center,
          child: Icon(_iconForIndex(i), color: color, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columns = getColumnIndices();
    final master = _masterOptions();
    final query = searchController.text.toLowerCase().trim();
    final activePrefix = selectedTabIndex == 0 ? '' : tabs[selectedTabIndex]['prefix']!;

    final filtered = master.where((f) {
      final ids = f.id.toLowerCase().split(',').map((s) => s.trim());
      final byTab = activePrefix.isEmpty || ids.any((id) => id.startsWith(activePrefix));
      final byQuery = query.isEmpty || f.name.toLowerCase().contains(query);
      return byTab && byQuery;
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 410),

        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2b2b2b), 
            border: Border.all(color: accent), 
            borderRadius: BorderRadius.circular(20)
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
            const SizedBox(height: 6),

            Text(
              'Select ${getTitle()}', 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: primaryText, 
                fontWeight: FontWeight.w600
              )
            ),
           
           const SizedBox(height: 12),
        
            // Top tabs (exclude All)
            Row(children: [for (int i = 1; i < tabs.length; i++) _tabButton(i)]),
            const SizedBox(height: 8),
            // Bottom-right All tab
            Row(children: [const Spacer(), SizedBox(width: 64, child: _tabButton(0))]),
        
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search..',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: secondaryText),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accent)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: darkGrey,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await showAddDishDialog(context);
                    setState(() {});
                  },
                  customBorder: const CircleBorder(),
                  child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.add, color: Colors.white60)),
                ),
              ),
            ]),
        
            const SizedBox(height: 12),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: filtered.isEmpty
                    ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No foods', style: TextStyle(color: Colors.white70)))
                    : Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          separatorBuilder: (_, __) => const SizedBox(height: 20),
                          itemBuilder: (ctx, i) {
                            final food = filtered[i];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop(food);
                                    final target = GoogleSheetsApi.findRowIndexByDate(widget.panelDate);
                                    if (target != -1) await GoogleSheetsApi.updateSingleMealSlot(rowIndex: target, columnIndex: widget.columnNumberToAddFood, foodId: food.id);
                                  },
                                  splashColor: Colors.white12,
                                  highlightColor: Colors.white10,
                                  child: Slidable(
                                    startActionPane: ActionPane(motion: const StretchMotion(), children: [
                                      SlidableAction(onPressed: (_) { HapticFeedback.lightImpact(); }, icon: Icons.info_outline, backgroundColor: fadedGrey),
                                    ]),
                                    endActionPane: ActionPane(motion: const StretchMotion(), children: [
                                      SlidableAction(onPressed: (_) { HapticFeedback.lightImpact(); }, icon: Icons.delete, backgroundColor: expRed),
                                    ]),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
                                      child: Row(children: [
                                        Container(height: 10, width: 10, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20))),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                            Text(food.name, style: const TextStyle(color: Colors.white, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 4),
                                            Text(() {
                                              final days = GoogleSheetsApi.calculateDaysSinceLastEaten(panelDate: widget.panelDate, columnIndices: columns, foodId: food.id);
                                              if (days == -1) return 'Never made';
                                              if (days == 1) return 'Made yesterday';
                                              return 'Made $days days ago';
                                            }(), style: TextStyle(color: fadedGrey, fontSize: 12)),
                                          ]),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
        
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

Widget foodList(BuildContext context, String panelDate, int columnNumberToAddFood, List<String> prefix) {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.zero,
    child: FoodSelectionDialog(panelDate: panelDate, columnNumberToAddFood: columnNumberToAddFood, prefix: prefix),
  );
}
