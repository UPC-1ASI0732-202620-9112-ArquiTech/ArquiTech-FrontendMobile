class WeekRange {
  WeekRange(DateTime date)
    : start = DateTime(date.year, date.month, date.day - (date.weekday - 1));
  final DateTime start;
  DateTime get endExclusive => DateTime(start.year, start.month, start.day + 7);
  DateTime get end => endExclusive.subtract(const Duration(milliseconds: 1));
  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(endExclusive);
}
