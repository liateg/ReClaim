/// Date/time formatting helpers used across item, claim and report views.
class DateFormatter {
  DateFormatter._();

  static const List<String> monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formats a [DateTime] as `MMM d, yyyy`, e.g. `Jun 5, 2026`.
  static String formatFull(DateTime? date) {
    if (date == null) return '';
    return '${monthsShort[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a [DateTime] as `dd/MM/yyyy`.
  static String formatShort(DateTime? date) {
    if (date == null) return 'Unknown date';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  /// Formats a date for the API as `yyyy-MM-dd`.
  static String formatForApi(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  /// Parses an ISO-8601 string, returning null when invalid or empty.
  static DateTime? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  /// Parses [value] then formats it with [formatFull]. Falls back to the raw
  /// string when it cannot be parsed.
  static String formatRaw(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) return value.trim();
    return formatFull(parsed);
  }

  /// Returns a coarse relative description such as `just now`, `5m ago`,
  /// `3h ago`, `2d ago`, or a full date for older values.
  static String timeAgo(DateTime? date, {DateTime? now}) {
    if (date == null) return '';
    final reference = now ?? DateTime.now();
    final diff = reference.difference(date);

    if (diff.isNegative) return 'just now';
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatFull(date);
  }
}
