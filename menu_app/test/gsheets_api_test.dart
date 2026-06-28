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
