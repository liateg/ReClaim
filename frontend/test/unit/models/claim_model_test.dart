import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/claims/data/models/claim_model.dart';
import 'package:frontend/features/claims/data/model/claim_model.dart';
import 'package:frontend/features/claims/enum/claim_status.dart';

void main() {
  group('ClaimModel (data model)', () {
    test('parses snake_case payload', () {
      final claim = ClaimModel.fromJson({
        'id': 1,
        'item_id': 2,
        'claimant_id': 3,
        'answer_attempt': 'blue',
        'status': 'pending',
        'review_note': 'ok',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-02T00:00:00.000Z',
      });

      expect(claim.id, 1);
      expect(claim.itemId, 2);
      expect(claim.claimantId, 3);
      expect(claim.answerAttempt, 'blue');
      expect(claim.status, 'pending');
      expect(claim.reviewNote, 'ok');
      expect(claim.createdAt, isNotNull);
    });

    test('parses camelCase and string ids', () {
      final claim = ClaimModel.fromJson({
        'id': '4',
        'itemId': '5',
        'claimantId': '6',
        'answerAttempt': 'x',
        'status': 'approved',
      });
      expect(claim.id, 4);
      expect(claim.itemId, 5);
      expect(claim.claimantId, 6);
      expect(claim.reviewNote, isNull);
    });

    test('throws when required id missing', () {
      expect(
        () => ClaimModel.fromJson({'itemId': 1, 'claimantId': 2}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson serializes to snake_case', () {
      final claim = ClaimModel(
        id: 1,
        itemId: 2,
        claimantId: 3,
        answerAttempt: 'a',
        status: 'pending',
      );
      final json = claim.toJson();
      expect(json['item_id'], 2);
      expect(json['claimant_id'], 3);
      expect(json['answer_attempt'], 'a');
    });
  });

  group('Claim (UI model)', () {
    test('parses json with defaults', () {
      final claim = Claim.fromJson({
        'id': 'c1',
        'date': '2026-01-01T00:00:00.000Z',
      });
      expect(claim.id, 'c1');
      expect(claim.title, 'Untitled Claim');
      expect(claim.category, 'Accessories');
      expect(claim.status, ClaimStatus.pending);
    });

    test('maps status strings case-insensitively', () {
      expect(
        Claim.fromJson({'id': 'a', 'status': 'APPROVED', 'date': '2026-01-01'})
            .status,
        ClaimStatus.approved,
      );
      expect(
        Claim.fromJson({'id': 'b', 'status': 'rejected', 'date': '2026-01-01'})
            .status,
        ClaimStatus.rejected,
      );
      expect(
        Claim.fromJson({'id': 'c', 'status': 'weird', 'date': '2026-01-01'})
            .status,
        ClaimStatus.pending,
      );
    });
  });

  group('ClaimStatus enum', () {
    test('has the expected values', () {
      expect(ClaimStatus.values,
          containsAll([ClaimStatus.pending, ClaimStatus.approved, ClaimStatus.rejected]));
    });
  });
}
