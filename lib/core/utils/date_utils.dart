import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static String displayDate(DateTime date, String locale) =>
      DateFormat.yMMMd(locale).format(date.toLocal());
  static String displayDateTime(DateTime date, String locale) =>
      DateFormat.yMMMd(locale).add_Hm().format(date.toLocal());
  static String utcIso(DateTime value) => value.toUtc().toIso8601String();
}
