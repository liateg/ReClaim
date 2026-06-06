import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/date_formatter.dart';

void main() {
  group('DateFormatter.formatFull', () {
    test('formats as MMM d, yyyy', () {
      expect(DateFormatter.formatFull(DateTime(2026, 6, 5)), 'Jun 5, 2026');
      expect(DateFormatter.formatFull(DateTime(2026, 1, 15)), 'Jan 15, 2026');
      expect(DateFormatter.formatFull(DateTime(2026, 12, 31)), 'Dec 31, 2026');
    });

    test('returns empty string for null', () {
      expect(DateFormatter.formatFull(null), '');
    });
  });

  group('DateFormatter.formatShort', () {
    test('zero-pads day and month', () {
      expect(DateFormatter.formatShort(DateTime(2026, 6, 5)), '05/06/2026');
    });
    test('returns placeholder for null', () {
      expect(DateFormatter.formatShort(null), 'Unknown date');
    });
  });

  group('DateFormatter.formatForApi', () {
    test('formats as yyyy-MM-dd with padding', () {
      expect(DateFormatter.formatForApi(DateTime(2026, 3, 9)), '2026-03-09');
    });
  });

  group('DateFormatter.tryParse', () {
    test('parses ISO strings', () {
      expect(DateFormatter.tryParse('2026-06-05'), DateTime.parse('2026-06-05'));
    });
    test('returns null for blank or invalid', () {
      expect(DateFormatter.tryParse(''), isNull);
      expect(DateFormatter.tryParse(null), isNull);
      expect(DateFormatter.tryParse('nope'), isNull);
    });
  });

  group('DateFormatter.formatRaw', () {
    test('formats a parseable string', () {
      expect(DateFormatter.formatRaw('2026-06-05'), 'Jun 5, 2026');
    });
    test('returns raw value when unparseable', () {
      expect(DateFormatter.formatRaw('someday'), 'someday');
    });
    test('returns empty for blank', () {
      expect(DateFormatter.formatRaw(''), '');
    });
  });

  group('DateFormatter.timeAgo', () {
    final now = DateTime(2026, 6, 5, 12, 0, 0);
    test('just now for recent times', () {
      expect(DateFormatter.timeAgo(now.subtract(const Duration(seconds: 5)), now: now),
          'just now');
    });
    test('minutes ago', () {
      expect(DateFormatter.timeAgo(now.subtract(const Duration(minutes: 5)), now: now),
          '5m ago');
    });
    test('hours ago', () {
      expect(DateFormatter.timeAgo(now.subtract(const Duration(hours: 3)), now: now),
          '3h ago');
    });
    test('days ago', () {
      expect(DateFormatter.timeAgo(now.subtract(const Duration(days: 2)), now: now),
          '2d ago');
    });
    test('older than a week shows full date', () {
      final old = DateTime(2026, 1, 1);
      expect(DateFormatter.timeAgo(old, now: now), 'Jan 1, 2026');
    });
    test('null returns empty', () {
      expect(DateFormatter.timeAgo(null), '');
    });
  });
}
