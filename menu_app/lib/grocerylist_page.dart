// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:menu_app/constants/colours.dart';
// import 'package:menu_app/constants/common_values.dart';
// import 'package:menu_app/gsheets_api.dart';

// class GroceryListPage extends StatefulWidget {
//   const GroceryListPage({super.key});

//   @override
//   State<GroceryListPage> createState() => _GroceryListPageState();
// }

// class _GroceryListPageState extends State<GroceryListPage> {
//   late final ScrollController _scrollController;
//   late final TextEditingController _newItemController;
//   late final FocusNode _newItemFocusNode;

//   bool _isAdding = false;
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _newItemController = TextEditingController();
//     _newItemFocusNode = FocusNode();

//     // When keyboard is dismissed or focus is lost, close the inline input row
//     _newItemFocusNode.addListener(() {
//       if (!_newItemFocusNode.hasFocus && !_isSubmitting) {
//         final text = _newItemController.text.trim();
//         if (text.isNotEmpty) {
//           _newItemController.clear();
//           GoogleSheetsApi.addGroceryItem(text);
//         }
//         if (_isAdding) {
//           setState(() {
//             _isAdding = false;
//           });
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _newItemController.dispose();
//     _newItemFocusNode.dispose();
//     super.dispose();
//   }

//   void _triggerInlineAdd() {
//     HapticFeedback.lightImpact();
//     setState(() {
//       _isAdding = true;
//     });
//     _newItemController.clear();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _newItemFocusNode.requestFocus();
//       _scrollToBottom();
//     });
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   // 2. Simplified _commitItem (no longer needs to manually re-request focus)
//   void _commitItem(String value) {
//     final text = value.trim();
//     if (text.isEmpty) {
//       _newItemFocusNode.unfocus();
//       setState(() {
//         _isAdding = false;
//       });
//       return;
//     }

//     _isSubmitting = true;

//     // Add locally and sync
//     setState(() {
//       GoogleSheetsApi.addGroceryItem(text);
//       _newItemController.clear();
//     });

//     // Auto scroll down while keyboard stays open seamlessly
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToBottom();
//       _isSubmitting = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: mainBg,
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           behavior: HitTestBehavior.opaque,
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 10),
//                 topBar(context),
//                 const SizedBox(height: 20),
//                 groceryListContent(),
//                 addButton(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget topBar(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             // Go back
//             IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: Icon(Icons.arrow_back_ios_new, color: blackText, size: 20),
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//             ),

//             Text(
//               "Grocery List",
//               style: TextStyle(
//                 color: text,
//                 fontSize: primaryText,
//                 fontWeight: FontWeight.w600,
//               ),
//               textHeightBehavior: const TextHeightBehavior(
//                 applyHeightToFirstAscent: false,
//                 applyHeightToLastDescent: false,
//               ),
//             ),
//           ],
//         ),

//         // Delete all items button
//         Material(
//           color: presentBg,
//           shape: const CircleBorder(),
//           child: InkWell(
//             onTap: () async {
//               HapticFeedback.lightImpact();
//               setState(() {
//                 _isAdding = false;
//                 GoogleSheetsApi.groceryItems.clear();
//               });

//               await GoogleSheetsApi.clearGroceryList();
//             },
//             customBorder: const CircleBorder(),
//             child: const Padding(
//               padding: EdgeInsets.all(10.0),
//               child: Icon(Icons.delete_forever, color: Colors.white70),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget groceryListContent() {
//     final items = GoogleSheetsApi.groceryItems;
//     final totalCount = items.length + (_isAdding ? 1 : 0);

//     return Expanded(
//       child: totalCount == 0
//           ? const Center(
//               child: Text(
//                 "Your grocery list is empty",
//                 style: TextStyle(color: Colors.white54, fontSize: 14),
//               ),
//             )
//           : ClipRRect(
//               borderRadius: BorderRadius.circular(rounding),
//               child: ListView.separated(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.only(bottom: 80),
//                 physics: const BouncingScrollPhysics(),
//                 itemCount: totalCount,
//                 separatorBuilder: (context, index) => const SizedBox(height: 2),
//                 itemBuilder: (context, index) {
//                   // Render the active inline entry line at the end
//                   if (index == items.length) {
//                     return buildInlineInputField();
//                   }

//                   final itemName = items[index][0];
//                   final bool isBought = items[index].length > 1 &&
//                       items[index][1].trim().toLowerCase() == 'y';

//                   final Color fadedBlack = Colors.black.withValues(alpha: 0.25);
//                   final Color containerBg = isBought
//                       ? Colors.white.withValues(alpha: 0.2)
//                       : Colors.white.withValues(alpha: 0.5);
//                   final Color textColor = isBought
//                       ? blackText.withValues(alpha: 0.35)
//                       : blackText;

//                   return AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                     decoration: BoxDecoration(
//                       color: containerBg,
//                       borderRadius: BorderRadius.circular(0),
//                     ),
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: () async {
//                         HapticFeedback.lightImpact();

//                         final currentStatus = (items[index].length > 1)
//                             ? items[index][1].trim().toLowerCase()
//                             : 'n';
//                         final newStatus = (currentStatus == 'y') ? 'n' : 'y';

//                         setState(() {
//                           items[index] = [items[index][0], newStatus];
//                         });

//                         await GoogleSheetsApi.toggleGroceryItemStatus(index, newStatus);
//                       },
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               itemName,
//                               style: TextStyle(
//                                 color: textColor,
//                                 fontSize: tertiaryText,
//                                 fontWeight: FontWeight.w200,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             width: 20,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: isBought ? fadedBlack : Colors.transparent,
//                               border: Border.all(
//                                 color: isBought ? fadedBlack : Colors.black,
//                                 width: 1.5,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//     );
//   }

//   // 3. Updated buildInlineInputField using onEditingComplete
//   Widget buildInlineInputField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.5),
//         borderRadius: BorderRadius.circular(0),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _newItemController,
//               focusNode: _newItemFocusNode,
//               textInputAction: TextInputAction.next,
//               textCapitalization: TextCapitalization.sentences,
//               style: TextStyle(
//                 color: blackText,
//                 fontSize: tertiaryText,
//                 fontWeight: FontWeight.w200,
//               ),
//               decoration: const InputDecoration(
//                 hintText: "Type item...",
//                 hintStyle: TextStyle(
//                   color: Colors.black38,
//                   fontWeight: FontWeight.w200,
//                 ),
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//               ),
//               // Overriding this prevents Flutter from hiding the keyboard on Enter
//               onEditingComplete: () {
//                 _commitItem(_newItemController.text);
//               },
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             width: 20,
//             height: 20,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.black.withValues(alpha: 0.4),
//                 width: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget addButton() {
//     return Material(
//       color: presentBg,
//       elevation: 4,
//       shape: const CircleBorder(),
//       child: InkWell(
//         onTap: _triggerInlineAdd,
//         customBorder: const CircleBorder(),
//         child: const Padding(
//           padding: EdgeInsets.all(14.0),
//           child: Icon(Icons.add, color: Colors.white, size: 24),
//         ),
//       ),
//     );
//   }
// }
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

class _GroceryListPageState extends State<GroceryListPage> with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  late final TextEditingController _newItemController;
  late final FocusNode _newItemFocusNode;

  bool _isAdding = false;
  bool _keyboardWasVisible = false; // Tracks if keyboard has actually opened

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _newItemController = TextEditingController();
    _newItemFocusNode = FocusNode();

    _newItemFocusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _newItemFocusNode.removeListener(_handleFocusChange);
    _scrollController.dispose();
    _newItemController.dispose();
    _newItemFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final bottomInset = View.of(context).viewInsets.bottom;

    // 1. Mark true once OS keyboard actually starts animating visible
    if (bottomInset > 0) {
      _keyboardWasVisible = true;
    } 
    // 2. Only unfocus if keyboard WAS visible and is now dismissed while still holding focus
    else if (bottomInset == 0 && _keyboardWasVisible && _newItemFocusNode.hasFocus) {
      _keyboardWasVisible = false;
      _newItemFocusNode.unfocus();
    }
  }

  void _handleFocusChange() {
    if (_newItemFocusNode.hasFocus) return;

    _keyboardWasVisible = false;
    final text = _newItemController.text.trim();
    if (text.isNotEmpty) {
      GoogleSheetsApi.addGroceryItem(text);
    }

    if (!mounted) return;
    setState(() {
      _isAdding = false;
      _newItemController.clear();
    });
  }

  void _triggerInlineAdd() {
    HapticFeedback.lightImpact();
    _keyboardWasVisible = false; // Reset before requesting focus
    setState(() => _isAdding = true);
    _newItemController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newItemFocusNode.requestFocus();
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _commitAndContinue() {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      GoogleSheetsApi.addGroceryItem(text);
      _newItemController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                topBar(context),
                const SizedBox(height: 20),
                groceryListContent(),
                addButton(),
              ],
            ),
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
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new, color: blackText, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text(
              "Grocery List",
              style: TextStyle(color: text, fontSize: primaryText, fontWeight: FontWeight.w600),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ],
        ),
        Material(
          color: presentBg,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              setState(() {
                _isAdding = false;
                GoogleSheetsApi.groceryItems.clear();
              });
              await GoogleSheetsApi.clearGroceryList();
            },
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.delete_forever, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  Widget groceryListContent() {
    final items = GoogleSheetsApi.groceryItems;
    final totalCount = items.length + (_isAdding ? 1 : 0);

    return Expanded(
      child: totalCount == 0
          ? const Center(
              child: Text(
                "Your grocery list is empty",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(rounding),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                physics: const BouncingScrollPhysics(),
                itemCount: totalCount,
                separatorBuilder: (context, index) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return buildInlineInputField();
                  }
                  return buildFoodTile(items, index);
                },
              ),
            ),
    );
  }

  Widget buildFoodTile(List<List<String>> items, int index) {
    final itemName = items[index][0];
    final bool isBought = items[index].length > 1 && items[index][1].trim().toLowerCase() == 'y';

    final Color fadedBlack = Colors.black.withValues(alpha: 0.25);
    final Color containerBg = isBought ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5);
    final Color textColor = isBought ? blackText.withValues(alpha: 0.35) : blackText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(color: containerBg, borderRadius: BorderRadius.circular(0)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          HapticFeedback.lightImpact();

          final currentStatus = (items[index].length > 1) ? items[index][1].trim().toLowerCase() : 'n';
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
                style: TextStyle(color: textColor, fontSize: tertiaryText, fontWeight: FontWeight.w200),
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
                border: Border.all(color: isBought ? fadedBlack : Colors.black, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInlineInputField() {
    return Container(
      key: const ValueKey('grocery_inline_input'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(0)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newItemController,
              focusNode: _newItemFocusNode,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: blackText, fontSize: tertiaryText, fontWeight: FontWeight.w200),
              decoration: const InputDecoration(
                hintText: "Type item...",
                hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.w200),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onEditingComplete: _commitAndContinue,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.4), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget addButton() {
    return Material(
      color: presentBg,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: _triggerInlineAdd,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(14.0),
          child: Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}