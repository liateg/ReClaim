import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/string_helpers.dart';

void main() {
  group('StringHelpers.isNullOrBlank', () {
    test('detects blank values', () {
      expect(StringHelpers.isNullOrBlank(null), isTrue);
      expect(StringHelpers.isNullOrBlank(''), isTrue);
      expect(StringHelpers.isNullOrBlank('   '), isTrue);
    });
    test('detects present values', () {
      expect(StringHelpers.isNullOrBlank('x'), isFalse);
    });
  });

  group('StringHelpers.capitalize', () {
    test('capitalizes first letter', () {
      expect(StringHelpers.capitalize('hello'), 'Hello');
    });
    test('leaves empty string untouched', () {
      expect(StringHelpers.capitalize(''), '');
    });
    test('does not lowercase the rest', () {
      expect(StringHelpers.capitalize('hELLO'), 'HELLO');
    });
  });

  group('StringHelpers.titleCase', () {
    test('title-cases each word', () {
      expect(StringHelpers.titleCase('hello world'), 'Hello World');
      expect(StringHelpers.titleCase('LOST AND found'), 'Lost And Found');
    });
    test('collapses extra whitespace', () {
      expect(StringHelpers.titleCase('  multiple   spaces '), 'Multiple Spaces');
    });
    test('empty stays empty', () {
      expect(StringHelpers.titleCase('   '), '');
    });
  });

  group('StringHelpers.truncate', () {
    test('keeps short strings intact', () {
      expect(StringHelpers.truncate('short', 10), 'short');
    });
    test('truncates and appends ellipsis', () {
      expect(StringHelpers.truncate('abcdefgh', 3), 'abc…');
    });
    test('custom ellipsis', () {
      expect(StringHelpers.truncate('abcdefgh', 3, ellipsis: '...'), 'abc...');
    });
  });

  group('StringHelpers.initials', () {
    test('handles full names', () {
      expect(StringHelpers.initials('Abebe Bikila'), 'AB');
    });
    test('handles single names', () {
      expect(StringHelpers.initials('Sara'), 'SA');
    });
    test('handles single character', () {
      expect(StringHelpers.initials('X'), 'X');
    });
    test('handles empty', () {
      expect(StringHelpers.initials('   '), '?');
    });
  });

  group('StringHelpers.orFallback', () {
    test('returns trimmed value when present', () {
      expect(StringHelpers.orFallback('  hi  ', 'fallback'), 'hi');
    });
    test('returns fallback when blank', () {
      expect(StringHelpers.orFallback('', 'fallback'), 'fallback');
      expect(StringHelpers.orFallback(null, 'fallback'), 'fallback');
    });
  });
}
