import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/data/models/profile_model.dart';

/// The app represents an authenticated user with [ProfileModel].
void main() {
  group('ProfileModel.fromJson', () {
    test('parses a standard user payload', () {
      final user = ProfileModel.fromJson({
        'id': 42,
        'email': 'abebe@aau.edu.et',
        'name': 'Abebe Bikila',
        'phone': '0911000000',
        'avatar_url': 'https://cdn/x.png',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-02-01T00:00:00.000Z',
      });

      expect(user.id, 42);
      expect(user.email, 'abebe@aau.edu.et');
      expect(user.name, 'Abebe Bikila');
      expect(user.phone, '0911000000');
      expect(user.avatarUrl, 'https://cdn/x.png');
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('accepts full_name as an alias for name', () {
      final user = ProfileModel.fromJson({
        'id': '3',
        'email': 'x@y.com',
        'full_name': 'Full Name',
      });
      expect(user.id, 3);
      expect(user.name, 'Full Name');
    });

    test('camelCase avatarUrl is supported', () {
      final user = ProfileModel.fromJson({
        'id': 1,
        'email': 'x@y.com',
        'name': 'X',
        'avatarUrl': 'https://a/b.png',
      });
      expect(user.avatarUrl, 'https://a/b.png');
    });

    test('defaults missing optional fields to null/empty', () {
      final user = ProfileModel.fromJson({'id': 1});
      expect(user.email, '');
      expect(user.name, '');
      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
    });

    test('throws when id is missing', () {
      expect(
        () => ProfileModel.fromJson({'email': 'x@y.com'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ProfileModel.toJson', () {
    test('serializes to snake_case and round-trips', () {
      final user = ProfileModel(
        id: 9,
        email: 'user@test.com',
        name: 'Test User',
        phone: '123',
      );

      final json = user.toJson();
      expect(json['email'], 'user@test.com');
      expect(json['name'], 'Test User');
      expect(json['phone'], '123');
      expect(json.containsKey('avatar_url'), isTrue);

      final restored = ProfileModel.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.name, user.name);
    });
  });
}
