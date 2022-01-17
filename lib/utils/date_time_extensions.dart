extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday(int date) {
    return day == date;
  }

  bool isBeforeDate(DateTime other) {
    if (year < other.year) {
      return true;
    }
    if (year == other.year && month < other.month) {
      return true;
    }
    if (year == other.year && month == other.month && day < other.day) {
      return true;
    }
    return false;
  }
}
