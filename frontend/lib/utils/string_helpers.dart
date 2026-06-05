/// Small string utilities used for display formatting.
class StringHelpers {
  StringHelpers._();

  /// True when [value] is null, empty, or only whitespace.
  static bool isNullOrBlank(String? value) =>
      value == null || value.trim().isEmpty;

  /// Capitalizes the first letter, leaving the rest untouched.
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Title-cases each whitespace separated word.
  static String titleCase(String value) {
    if (value.trim().isEmpty) return '';
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) => capitalize(word.toLowerCase()))
        .join(' ');
  }

  /// Truncates [value] to [maxLength] characters, appending [ellipsis] when
  /// the value was longer.
  static String truncate(String value, int maxLength, {String ellipsis = '…'}) {
    if (maxLength <= 0) return ellipsis;
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength) + ellipsis;
  }

  /// Builds up to two uppercase initials from a person's name.
  static String initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final word = parts.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Returns [value] when not blank, otherwise [fallback].
  static String orFallback(String? value, String fallback) {
    return isNullOrBlank(value) ? fallback : value!.trim();
  }
}
