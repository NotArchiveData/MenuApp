import 'dart:async';
import 'package:flutter/material.dart';

class FunLoadingDialog extends StatefulWidget {
  final List<String> statusMessages;

  const FunLoadingDialog({
    super.key,
    this.statusMessages = const [
      "Getting things in order...",
      "Petting a dog...",
      "Sorting out the veggies...",
      "Matching your meals...",
      "Balancing the macro universe...",
      "Writing to Google Sheets...",
      "Almost done!",
    ],
  });

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FunLoadingDialog(),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  State<FunLoadingDialog> createState() => _FunLoadingDialogState();
}

class _FunLoadingDialogState extends State<FunLoadingDialog> {
  int _messageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % widget.statusMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.statusMessages[_messageIndex],
                key: ValueKey<int>(_messageIndex),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}