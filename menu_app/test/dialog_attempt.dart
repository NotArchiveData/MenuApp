import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DummyFoodDialog extends StatefulWidget {
  const DummyFoodDialog({super.key});

  @override
  State<DummyFoodDialog> createState() => _DummyFoodDialogState();
}

class _DummyFoodDialogState extends State<DummyFoodDialog> {
  int selectedTabIndex = 0; // Unified index from 0 to 6
  final Color accent = Colors.orange;
  final Color panelBg = const Color(0xFF2b2b2b);

  // Top Tabs (Indices 0, 1, 2, 3)
  final List<String> topTabIcons = [
    "assets/icons/carb.svg",
    "assets/icons/nonveg.svg",
    "assets/icons/veg.svg",
    "assets/icons/fruit.svg",
  ];

  // Bottom Tabs (Indices 4, 5, 6)
  final List<String> bottomTabIcons = [
    "assets/icons/dessert.svg",
    "assets/icons/drink.svg",
    "assets/icons/everything.svg",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 480,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            return Stack(
              children: [
                // --- LAYER 1: DYNAMIC BACKGROUND FRAME ---
                Positioned.fill(
                  child: CustomPaint(
                    painter: DialogFramePainter(
                      selectedTabIndex: selectedTabIndex,
                      accent: accent,
                      backgroundColor: panelBg,
                    ),
                  ),
                ),

                // --- LAYER 2: INNER CONTENT PANEL ---
                Positioned(
                  top: 42,
                  bottom: 42,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Center(
                      child: _buildPanelContent(selectedTabIndex),
                    ),
                  ),
                ),

                // --- LAYER 3: TOP INTERACTIVE TABS ---
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(topTabIcons.length, (index) {
                      final bool isSelected = selectedTabIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => selectedTabIndex = index),
                        child: Container(
                          width: 70,
                          height: isSelected ? 42 : 40,
                          alignment: Alignment.center,
                          decoration: isSelected
                              ? const BoxDecoration(color: Colors.transparent) // Drawn by painter
                              : BoxDecoration(
                                  color: const Color(0xFF1c1c1c),
                                  border: Border.all(color: Colors.white10, width: 1.5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(index == 0 ? 20 : 14),
                                    topRight: Radius.circular(index == 3 ? 20 : 14),
                                  ),
                                ),
                          child: SvgPicture.asset(
                            topTabIcons[index],
                            colorFilter: ColorFilter.mode(
                              isSelected ? Colors.white : Colors.white38,
                              BlendMode.srcIn,
                            ),
                            width: 15,
                            height: 15,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // --- LAYER 4: BOTTOM INTERACTIVE TABS ---
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(bottomTabIcons.length, (index) {
                      final int actualIndex = index + 4; // Map to unified index (4, 5, 6)
                      final bool isSelected = selectedTabIndex == actualIndex;

                      return GestureDetector(
                        onTap: () => setState(() => selectedTabIndex = actualIndex),
                        child: Container(
                          width: 70,
                          height: isSelected ? 42 : 40,
                          alignment: Alignment.center,
                          decoration: isSelected
                              ? const BoxDecoration(color: Colors.transparent) // Drawn by painter
                              : BoxDecoration(
                                  color: const Color(0xFF1c1c1c),
                                  border: Border.all(color: Colors.white10, width: 1.5),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(index == 0 ? 20 : 14),
                                    bottomRight: Radius.circular(index == 2 ? 20 : 14),
                                  ),
                                ),
                          child: SvgPicture.asset(
                            bottomTabIcons[index],
                            colorFilter: ColorFilter.mode(
                              isSelected ? Colors.white : Colors.white38,
                              BlendMode.srcIn,
                            ),
                            width: 15,
                            height: 15,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Swap out layout panel view components depending on unified index
  Widget _buildPanelContent(int index) {
    switch (index) {
      case 0: return const Text("Carbs Content View", style: TextStyle(color: Colors.white, fontSize: 18));
      case 1: return const Text("Non-Veg Content View", style: TextStyle(color: Colors.white, fontSize: 18));
      case 2: return const Text("Veg Content View", style: TextStyle(color: Colors.white, fontSize: 18));
      case 3: return const Text("Fruit Content View", style: TextStyle(color: Colors.white, fontSize: 18));
      case 4: return const Text("Bottom Tab 1 Content", style: TextStyle(color: Colors.white, fontSize: 18));
      case 5: return const Text("Bottom Tab 2 Content", style: TextStyle(color: Colors.white, fontSize: 18));
      case 6: return const Text("Bottom Tab 3 Content", style: TextStyle(color: Colors.white, fontSize: 18));
      default: return const SizedBox.shrink();
    }
  }
}

// --- MATHEMATICAL VECTOR PAINTER FOR OUTWARD FILLETS AND CORNER RADIUS ---
class DialogFramePainter extends CustomPainter {
  final int selectedTabIndex;
  final Color accent;
  final Color backgroundColor;

  DialogFramePainter({
    required this.selectedTabIndex,
    required this.accent,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double mainTop = 42;
    final double mainBottom = h - 42;

    // Row-matching mathematical coordinate distribution
    final double topSpacing = (w - 4 * 70) / 3;
    double topLeft(int i) => i * (70 + topSpacing);
    double topRight(int i) => topLeft(i) + 70;

    final double bottomSpacing = (w - 3 * 70) / 2;
    double bottomLeft(int i) => (i - 4) * (70 + bottomSpacing);
    double bottomRight(int i) => bottomLeft(i) + 70;

    // --- 1. TOP LEFT CORNER & TOP TABS ---
    if (selectedTabIndex == 0) {
      path.moveTo(0, mainTop + 20);
      path.lineTo(0, 20); // Extend upward to form corner
      path.arcToPoint(const Offset(20, 0), radius: const Radius.circular(20), clockwise: true);
      path.lineTo(70 - 14, 0);
      path.arcToPoint(const Offset(70, 14), radius: const Radius.circular(14), clockwise: true);
      path.lineTo(70, mainTop - 10);
      path.arcToPoint(Offset(70 + 10, mainTop), radius: const Radius.circular(10), clockwise: false); // Outward Fillet
    } else {
      path.moveTo(0, mainTop + 20);
      path.arcToPoint(Offset(20, mainTop), radius: const Radius.circular(20), clockwise: true);
      
      if (selectedTabIndex == 1 || selectedTabIndex == 2) {
        double L = topLeft(selectedTabIndex);
        double R = topRight(selectedTabIndex);
        path.lineTo(L - 10, mainTop);
        path.arcToPoint(Offset(L, mainTop - 10), radius: const Radius.circular(10), clockwise: false); // Outward Left
        path.lineTo(L, 14);
        path.arcToPoint(Offset(L + 14, 0), radius: const Radius.circular(14), clockwise: true);
        path.lineTo(R - 14, 0);
        path.arcToPoint(Offset(R, 14), radius: const Radius.circular(14), clockwise: true);
        path.lineTo(R, mainTop - 10);
        path.arcToPoint(Offset(R + 10, mainTop), radius: const Radius.circular(10), clockwise: false); // Outward Right
      }
    }

    // --- 2. TOP RIGHT CORNER ---
    if (selectedTabIndex == 3) {
      double L = topLeft(3);
      path.lineTo(L - 10, mainTop);
      path.arcToPoint(Offset(L, mainTop - 10), radius: const Radius.circular(10), clockwise: false);
      path.lineTo(L, 14);
      path.arcToPoint(Offset(L + 14, 0), radius: const Radius.circular(14), clockwise: true);
      path.lineTo(w - 20, 0);
      path.arcToPoint(Offset(w, 20), radius: const Radius.circular(20), clockwise: true);
      path.lineTo(w, mainBottom - 20);
    } else {
      path.lineTo(w - 20, mainTop);
      path.arcToPoint(Offset(w, mainTop + 20), radius: const Radius.circular(20), clockwise: true);
      path.lineTo(w, mainBottom - 20);
    }

    // --- 3. BOTTOM RIGHT CORNER & BOTTOM TABS ---
    if (selectedTabIndex == 6) {
      double L = bottomLeft(6);
      path.lineTo(w, h - 20); // Extend downward to form corner
      path.arcToPoint(Offset(w - 20, h), radius: const Radius.circular(20), clockwise: true);
      path.lineTo(L + 14, h);
      path.arcToPoint(Offset(L, h - 14), radius: const Radius.circular(14), clockwise: true);
      path.lineTo(L, mainBottom + 10);
      path.arcToPoint(Offset(L - 10, mainBottom), radius: const Radius.circular(10), clockwise: false); // Outward Fillet
    } else {
      path.arcToPoint(Offset(w - 20, mainBottom), radius: const Radius.circular(20), clockwise: true);
      
      if (selectedTabIndex == 5) {
        double L = bottomLeft(5);
        double R = bottomRight(5);
        path.lineTo(R + 10, mainBottom);
        path.arcToPoint(Offset(R, mainBottom + 10), radius: const Radius.circular(10), clockwise: false);
        path.lineTo(R, h - 14);
        path.arcToPoint(Offset(R - 14, h), radius: const Radius.circular(14), clockwise: true);
        path.lineTo(L + 14, h);
        path.arcToPoint(Offset(L, h - 14), radius: const Radius.circular(14), clockwise: true);
        path.lineTo(L, mainBottom + 10);
        path.arcToPoint(Offset(L - 10, mainBottom), radius: const Radius.circular(10), clockwise: false);
      }
    }

    // --- 4. BOTTOM LEFT CORNER ---
    if (selectedTabIndex == 4) {
      double R = bottomRight(4);
      path.lineTo(R + 10, mainBottom);
      path.arcToPoint(Offset(R, mainBottom + 10), radius: const Radius.circular(10), clockwise: false);
      path.lineTo(R, h - 14);
      path.arcToPoint(Offset(R - 14, h), radius: const Radius.circular(14), clockwise: true);
      path.lineTo(20, h);
      path.arcToPoint(Offset(0, h - 20), radius: const Radius.circular(20), clockwise: true);
    } else {
      path.lineTo(20, mainBottom);
      path.arcToPoint(Offset(0, mainBottom - 20), radius: const Radius.circular(20), clockwise: true);
    }

    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant DialogFramePainter oldDelegate) {
    return oldDelegate.selectedTabIndex != selectedTabIndex ||
        oldDelegate.accent != accent ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

