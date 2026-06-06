import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/validators.dart';

void main() {
  group('Validators.isValidEmail', () {
    test('accepts well-formed emails', () {
      expect(Validators.isValidEmail('abebe@aau.edu.et'), isTrue);
      expect(Validators.isValidEmail('user.name@domain.com'), isTrue);
    });

    test('rejects malformed emails', () {
      expect(Validators.isValidEmail('not-an-email'), isFalse);
      expect(Validators.isValidEmail('a@b'), isFalse);
      expect(Validators.isValidEmail('@b.com'), isFalse);
      expect(Validators.isValidEmail(null), isFalse);
    });
  });

  group('Validators.required', () {
    test('returns error for blank values', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required(null), isNotNull);
    });

    test('returns null for present values', () {
      expect(Validators.required('x'), isNull);
    });

    test('includes the field name in the message', () {
      expect(Validators.required('', field: 'Email'), contains('Email'));
    });
  });

  group('Validators.email', () {
    test('flags missing email', () {
      expect(Validators.email(''), contains('required'));
    });
    test('flags invalid email', () {
      expect(Validators.email('bad'), 'Enter a valid email address');
    });
    test('passes valid email', () {
      expect(Validators.email('a@b.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(''), contains('required'));
    });
    test('enforces minimum length', () {
      expect(Validators.password('123'), contains('at least 6'));
    });
    test('accepts a valid password', () {
      expect(Validators.password('secret1'), isNull);
    });
    test('honors a custom minimum length', () {
      expect(Validators.password('1234', minLength: 4), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('requires confirmation', () {
      expect(Validators.confirmPassword('abc', ''), isNotNull);
    });
    test('flags mismatches', () {
      expect(Validators.confirmPassword('abc', 'xyz'), 'Passwords do not match');
    });
    test('passes when matching', () {
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
    });
  });

  group('Validators.name', () {
    test('requires a value', () {
      expect(Validators.name(''), contains('required'));
    });
    test('enforces minimum length', () {
      expect(Validators.name('a'), contains('at least 2'));
    });
    test('accepts a valid name', () {
      expect(Validators.name('Sara'), isNull);
    });
  });
}
