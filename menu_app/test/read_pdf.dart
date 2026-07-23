// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:menu_app/gsheets_api.dart';

// // Imports for your custom helper files
// import 'package:menu_app/testingg/loadingoverlay.dart';
// import 'package:menu_app/testingg/pdf_parsing.dart';

// class ReadPdfPage extends StatefulWidget {
//   const ReadPdfPage({super.key});
  

//   @override
//   State<ReadPdfPage> createState() => _ReadPdfPageState();
// }

// class _ReadPdfPageState extends State<ReadPdfPage> {
//   final String mockJson = '''{"breakfast":{"1":["egg omelette","veggies","green chutney"],"2":["sourdough toast"],"3":["ragi","oats","rice flour","egg"],"4":["kacha kela","peanut butter toast"],"5":["peanut","corn","veggies salad"],"6":["ragi pancake"]},"lunch":{"1":["rice","palak paneer","salad"],"2":["quinoa veggies pulao","amaranth saag"],"3":["rice","mutton curry","mix salad"],"4":["rice","tori sabzi","paneer","salad"],"5":["rice","soya matter sabzi","salad"],"6":["rice","quinoa","fish","bhindi sabzi","salad"],"7":["curd rice","lauki sabzi"]},"dinner":{"1":["ragi roti","mix veg","salad"],"2":["veggies","khichdi"],"3":["chicken","corn veggies salad"],"4":["mushroom beans carrot","fish","ragi roti"],"5":["ragi","paneer capsicum sabzi","salad"],"6":["mix veg chila","pumpkin sabzi","pumpkin tomato soup","egg bhurji"],"7":["brocolli and tofu tikki","green chutney"]}}''';

//   String _status = "No PDF loaded yet";
  

//   static const String _geminiApiKey = "";

//   void printFullString(String text) {
//     final pattern = RegExp('.{1,800}');
//     pattern.allMatches(text).forEach((match) => print(match.group(0)));
//   }

//   Future<void> _pickAndReadPdf() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );

//     if (result == null || result.files.single.path == null) {
//       setState(() => _status = "No file selected");
//       return;
//     }

//     final filePath = result.files.single.path!;

//     try {
//       setState(() => _status = "Reading raw PDF file...");

//       final pdfBytes = await File(filePath).readAsBytes();
//       final base64Pdf = base64Encode(pdfBytes);

//       setState(() => _status = "Extracting full JSON with Gemini...");

//       final prompt = '''
// Look ONLY at Page 2 of this PDF document. Ignore Page 1, Page 3, and Page 4.

// Extract all meal options listed under "Breakfast", "Lunch", and "Dinner" on Page 2 into JSON.

// Formatting Rules:
// 1. Include ALL numbered items listed under Breakfast, Lunch, and Dinner.
// 2. ONLY include numbered options that actually contain food text. Skip blank or empty numbers completely.
// 3. Use string numbers ("1", "2", "3", etc.) for option keys.
// 4. Keep food names concise and clean (2-4 words max per item).
// 5. Remove all quantities ("1 bowl", "1 katori", "1-2 full", "1 pc"), prep directions ("stir fry", "pan fry", "boiled"), and instructions in parentheses.
// 6. Split combined items connected by "+" or "with" into separate array strings.
// 7. Output compact, minified JSON on a single line without extra line breaks or indentation.

// Return a single complete JSON object containing "breakfast", "lunch", and "dinner" keys.
// ''';

//       final url = Uri.parse(
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_geminiApiKey',
//       );

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [
//             {
//               "parts": [
//                 {"text": prompt},
//                 {
//                   "inline_data": {
//                     "mime_type": "application/pdf",
//                     "data": base64Pdf,
//                   }
//                 }
//               ]
//             }
//           ],
//           "generationConfig": {
//             "responseMimeType": "application/json",
//             "maxOutputTokens": 8192,
//             "temperature": 0.1,
//           }
//         }),
//       );

//       if (response.statusCode != 200) {
//         print("Gemini request failed (${response.statusCode}): ${response.body}");
//         setState(() => _status = "Request failed (${response.statusCode}). Check console.");
//         return;
//       }

//       final decoded = jsonDecode(response.body);
//       final rawJsonText = decoded['candidates'][0]['content']['parts'][0]['text'];

//       print("================ COMPLETE JSON ================");
//       printFullString(rawJsonText);
//       print("===============================================");

//       setState(() => _status = "Success! Saving to Google Sheets...");

//       // Automatically trigger the full parsing & Google Sheets update pipeline
//       await _processAndSaveDietPlan(rawJsonText);

//     } catch (e) {
//       print("Error processing PDF: $e");
//       setState(() => _status = "Error processing PDF: $e");
//     }
//   }

//   /// Parses raw JSON, matches Food IDs, and updates Google Sheets
//   Future<void> _processAndSaveDietPlan(String rawJson) async {
//     FunLoadingDialog.show(context);

//     try {
//       // 1. Parse raw JSON into structured WeeklyDietPlan
//       final dietPlan = WeeklyDietPlan.fromJsonString(rawJson);

//       // 2. Map dish names against static food list from GoogleSheetsApi
//       final updates = DietPlanMapper.buildCalendarUpdates(
//         plan: dietPlan,
//         foodItems: GoogleSheetsApi.foodItems, 
//         startDate: DateTime.now(),
//       );

//       // 3. Update local matrix and push directly to Google Sheets!
//       await GoogleSheetsApi.applyPlanToCalendar(
//         dayUpdates: updates,
//       );

//       if (mounted) {
//         FunLoadingDialog.hide(context);
//         setState(() => _status = "Diet plan applied to Google Sheets!");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Weekly diet plan updated successfully!")),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         FunLoadingDialog.hide(context);
//         setState(() => _status = "Error updating sheet: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error updating plan: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _status,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 20),
//                 // ElevatedButton(
//                 //   onPressed: () async {
//                 //     // Pick PDF -> Call Gemini -> Get rawJson -> Process
//                 //     final pdfText = await pickAndExtractPdf();
//                 //     final rawJson = await callGeminiApi(pdfText); // ❌ Wasting API calls
//                 //     await _processAndSaveDietPlan(rawJson);
//                 //   },
//                 //   child: const Text("Import PDF"),
//                 // ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     // Skip PDF & Gemini completely, feed mockJson directly!
//                     await _processAndSaveDietPlan(mockJson);
//                   },
//                   child: const Text("Test Run (No API)"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }