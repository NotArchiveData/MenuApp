// import 'package:flutter_test/flutter_test.dart';
// import 'package:menu_app/gsheets_api.dart';

// void main() {
//   group('GoogleSheetsApi food option filtering', () {
//     setUp(() {
//       GoogleSheetsApi.foodItems = [
//         ['c01', '', 'Carb One', ''],
//         ['nv01', '', 'Non-Veg One', ''],
//         ['v01', '', 'Veg One', ''],
//         ['c02', '', 'Carb Two', ''],
//         ['nv02', '', 'Non-Veg Two', ''],
//       ];
//     });

//     test('returns only options whose ids start with the requested prefix', () {
//       final carbOptions = GoogleSheetsApi.getFoodOptionsByPrefix('c');
//       final dishOptions = GoogleSheetsApi.getFoodOptionsByPrefix('nv');

//       expect(carbOptions.map((option) => option.name).toList(), ['Carb One', 'Carb Two']);
//       expect(dishOptions.map((option) => option.name).toList(), ['Non-Veg One', 'Non-Veg Two']);
//     });
//   });
// }


  // static Future<String?> fetchImageUrlFromSheet(int column, int row) async {
  //   if (foodList == null) return null;

  //   final value = await foodList!.values.value(column: column, row: row);
  //   final link = value.toString().trim();
  //   if (link.isEmpty) return null;

  //   final uri = Uri.tryParse(link);
  //   if (uri == null) return null;

  //   final queryId = uri.queryParameters['id'];
  //   if (queryId != null && queryId.isNotEmpty) {
  //     return "https://drive.google.com/uc?export=view&id=$queryId";
  //   }

  //   final match = RegExp(r'/d/([a-zA-Z0-9-_]+)').firstMatch(link);
  //   if (match != null) {
  //     return "https://drive.google.com/uc?export=view&id=${match.group(1)}";
  //   }

  //   return null;
  // }
