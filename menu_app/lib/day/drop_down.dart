import 'package:flutter/material.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';
import 'package:menu_app/gsheets_api.dart';

// Holds the configuration for one dropdown inside a meal section.
class DropdownConfig {
  final String key;
  final String hintText;
  final List<String> prefixes;

  const DropdownConfig({
    required this.key,
    required this.hintText,
    required this.prefixes,
  });
}

// The shared meal section widget that composes several dropdowns.
class MealSection extends StatefulWidget {
  final String title;
  final List<DropdownConfig> dropdownConfigs;

  const MealSection({
    super.key,
    required this.title,
    required this.dropdownConfigs,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {
  final Map<String, FoodOption?> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: white,
            fontSize: secondaryText,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.dropdownConfigs.length >= 2)
          Row(
            children: [
              Expanded(child: _buildDropdownWidget(widget.dropdownConfigs[0])),
              const SizedBox(width: 8),
              Expanded(child: _buildDropdownWidget(widget.dropdownConfigs[1])),
            ],
          ),
        if (widget.dropdownConfigs.length > 2) ...[
          const SizedBox(height: 8),
          _buildDropdownWidget(widget.dropdownConfigs[2]),
        ],
      ],
    );
  }

  Widget _buildDropdownWidget(DropdownConfig config) {
    final options = GoogleSheetsApi.getFoodOptionsByPrefix(config.prefixes);

    return FoodDropdown(
      hintText: config.hintText,
      options: options,
      value: _selectedOptions[config.key],
      onChanged: (option) {
        setState(() {
          _selectedOptions[config.key] = option;
        });
      },
    );
  }
}

// Reusable dropdown card used for the meal selection UI.
class FoodDropdown extends StatelessWidget {
  final String hintText;
  final List<FoodOption> options;
  final FoodOption? value;
  final ValueChanged<FoodOption?> onChanged;

  const FoodDropdown({
    super.key,
    required this.hintText,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Outer card that wraps the dropdown and gives it the rounded container style.
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: white.withValues(alpha: 0.08),
        ),
        padding: const EdgeInsets.all(8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<FoodOption>(
            isExpanded: true,
            value: value,
            hint: _buildSelectionRow(hintText, isSelected: false),
            selectedItemBuilder: (context) {
              if (value == null) {
                return [_buildSelectionRow(hintText, isSelected: false)];
              }
              return [_buildSelectionRow(value!.name, isSelected: true)];
            },
            dropdownColor: darkGrey,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
            // Each option shows the name and the tertiary text line.
            items: options
                .map(
                  (option) => DropdownMenuItem<FoodOption>(
                    value: option,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.name,
                                  style: TextStyle(
                                    color: white,
                                    fontSize: secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  option.tertiaryText,
                                  style: TextStyle(
                                    color: lightGrey,
                                    fontSize: tertiaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // The visible row inside the closed dropdown, showing the placeholder or selected value.
  Widget _buildSelectionRow(String label, {required bool isSelected}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? white : white.withValues(alpha: 0.75),
              fontSize: secondaryText,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

