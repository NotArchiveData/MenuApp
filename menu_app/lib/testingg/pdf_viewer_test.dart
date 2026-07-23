import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:menu_app/constants/api.dart' as api;

const String dietPlanExtractionPrompt = '''
Look ONLY at Page 2 of this PDF document. Ignore Page 1, Page 3, and Page 4.

Extract all meal options listed under "Breakfast", "Lunch", and "Dinner" on Page 2 into JSON.

CRITICAL SPLITTING RULES (read carefully, these are the most important part):

1. Only split a line into multiple separate dishes when it lists genuinely
   distinct, separately-served items. Do NOT split when "with" or "+" is
   part of ONE dish's own descriptive name.
   Example: "egg omelette with veggies" is ONE dish (an omelette that
   contains veggies) — do not split it into "egg omelette" and "veggies".
   Example: "peanut butter toast" is TWO separate items — "peanut butter"
   and "toast" — since these are two things served together, not one
   dish's name.
   If you are unsure whether something is one dish or two, prefer keeping
   it as ONE dish rather than splitting it.

2. Parentheses often contain BOTH real additional food items (condiments,
   sides, extra ingredients) AND non-food cooking instructions. You must
   tell these apart:
   - Extract real food items from inside parentheses as their own
     separate entries (e.g. "(add dhania chutney + guacamole)" contains
     two real food items: "dhania chutney" and "guacamole" — include both).
   - Discard genuine instructions with no food content (e.g. "soak
     overnight", "mix well", "add water", "little pan fry with spices").

3. Some lines describe a RECIPE made by combining raw ingredients into
   ONE final prepared dish (look for phrasing like "mix all", "equal
   portion", "make dosa/chila/pancake"). In this case:
   - Treat the combined raw ingredients as ONE single dish, named after
     what it becomes (e.g. "ragi + oats + rice flour, mix all, make dosa"
     becomes ONE entry: "ragi oats dosa").
   - Any item served ALONGSIDE that dish (e.g. "+ 1 boiled egg" after the
     recipe instructions) should still be its OWN separate entry, since
     it's a separate food, not part of the recipe being combined.

OTHER FORMATTING RULES:

4. Include ALL numbered items listed under Breakfast, Lunch, and Dinner.
5. ONLY include numbered options that actually contain food text. Skip
   blank or empty numbers completely.
6. Use string numbers ("1", "2", "3", etc.) for option keys.
7. Keep each food name concise (2-4 words), removing quantities ("1 bowl",
   "1 katori", "2 pc"), but do NOT remove real food words while doing so.
8. Output compact, minified JSON on a single line, no line breaks or
   indentation, no commentary before or after the JSON.

Return a single complete JSON object containing "breakfast", "lunch", and
"dinner" keys, each mapping option numbers to arrays of dish name strings.
''';

class PdfViewerTestPage extends StatefulWidget {
  const PdfViewerTestPage({super.key});

  @override
  State<PdfViewerTestPage> createState() => PdfViewerTestPageState();
}

class PdfViewerTestPageState extends State<PdfViewerTestPage> {
  String status = "No PDF loaded yet";

  // TEMPORARY: replace with your real key, don't commit it once you're done testing.
  static const String geminiApiKey = api.geminiApiKey;

  void printFullString(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<void> pickAndSendPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) {
      setState(() => status = "No file selected");
      return;
    }

    setState(() => status = "Sending PDF to Gemini...");

    try {
      final pdfBytes = await File(result.files.single.path!).readAsBytes();
      final base64Pdf = base64Encode(pdfBytes);

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": dietPlanExtractionPrompt},
                {
                  "inline_data": {
                    "mime_type": "application/pdf",
                    "data": base64Pdf,
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json",
            "maxOutputTokens": 8192,
            "temperature": 0.1,
          }
        }),
      );

      if (response.statusCode != 200) {
        print("Gemini request failed (${response.statusCode}): ${response.body}");
        setState(() => status = "Request failed (${response.statusCode}). Check console.");
        return;
      }

      final decoded = jsonDecode(response.body);
      final rawJsonText = decoded['candidates'][0]['content']['parts'][0]['text'];

      print("================ GEMINI RESPONSE (copy this into mockDietPlanJson) ================");
      printFullString(rawJsonText);
      print("=====================================================================================");

      setState(() => status = "Done — response printed to console.");
    } catch (e) {
      print("Error sending PDF to Gemini: $e");
      setState(() => status = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: pickAndSendPdf,
                  child: const Text("Send PDF to Gemini (test)"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}