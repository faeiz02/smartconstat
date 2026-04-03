class DateFormatter {
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  static int getDaysLeft(DateTime endDate) {
    return endDate.difference(DateTime.now()).inDays;
  }

  static double getProgressPercentage(DateTime startDate, DateTime endDate) {
    final totalDays = endDate.difference(startDate).inDays;
    final daysPassed = DateTime.now().difference(startDate).inDays;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }
}