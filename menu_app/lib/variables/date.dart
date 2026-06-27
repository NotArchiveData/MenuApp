import 'package:intl/intl.dart';

// get current date to display
String getDayMonthYear() {
  DateTime now = DateTime.now();
  String day = DateFormat('d').format(now);
  String month = DateFormat('MMMM').format(now);
  String year = DateFormat('yyyy').format(now);
  String suffix;

  if (day.endsWith('1') && day != '11') {
    suffix = 'st';
  } else if (day.endsWith('2') && day != '12') {
    suffix = 'nd';
  } else if (day.endsWith('3') && day != '13') {
    suffix = 'rd';
  } else {
    suffix = 'th';
  }

  return '$day$suffix $month $year';
}

// get date in yyyy-mm-dd format
String getDate() {
  DateTime now = DateTime.now();
  String day = DateFormat('dd').format(now);
  String month = DateFormat('MM').format(now);
  String year = DateFormat('yyyy').format(now);

  return "$year-$month-$day";
}