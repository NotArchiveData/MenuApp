import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_app/constants/colours.dart';
import 'package:menu_app/constants/common_values.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cyanBg,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                // child: Icon(Icons.exit_to_app, color: Colors.white),
                child: Icon(Icons.refresh, color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
