import 'package:intl/intl.dart';

// get current date to display
String getDayMonthYear() {
  DateTime now = DateTime.now();
  String month = DateFormat('MMMM').format(now);
  String year = DateFormat('yyyy').format(now);

  return '$month $year';
}

// get date in yyyy-mm-dd format
String getDate() {
  DateTime now = DateTime.now();
  String day = DateFormat('dd').format(now);
  String month = DateFormat('MM').format(now);
  String year = DateFormat('yyyy').format(now);

  return "$year-$month-$day";
}

// get date in dd-MMMM format