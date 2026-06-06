import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/reports/data/models/report_model.dart';

void main() {
  group('ReportReason', () {
    test('displayName maps each value', () {
      expect(ReportReason.fake.displayName, 'Fake Item');
      expect(ReportReason.spam.displayName, 'Spam');
      expect(ReportReason.wrong_owner.displayName, 'Wrong Owner');
      expect(ReportReason.other.displayName, 'Other');
    });

    test('fromString parses known values', () {
      expect(ReportReason.fromString('fake'), ReportReason.fake);
      expect(ReportReason.fromString('wrong_owner'), ReportReason.wrong_owner);
    });

    test('fromString falls back to other for unknown values', () {
      expect(ReportReason.fromString('nope'), ReportReason.other);
      expect(ReportReason.fromString(''), ReportReason.other);
    });
  });

  group('ReportStatus', () {
    test('displayName maps each value', () {
      expect(ReportStatus.pending.displayName, 'Pending');
      expect(ReportStatus.under_review.displayName, 'Under Review');
      expect(ReportStatus.resolved.displayName, 'Resolved');
      expect(ReportStatus.rejected.displayName, 'Rejected');
    });

    test('color maps each value', () {
      expect(ReportStatus.pending.color, Colors.orange);
      expect(ReportStatus.under_review.color, Colors.blue);
      expect(ReportStatus.resolved.color, Colors.green);
      expect(ReportStatus.rejected.color, Colors.red);
    });

    test('fromString falls back to pending', () {
      expect(ReportStatus.fromString('resolved'), ReportStatus.resolved);
      expect(ReportStatus.fromString('unknown'), ReportStatus.pending);
    });
  });

  group('Report.fromJson', () {
    test('parses snake_case payload', () {
      final report = Report.fromJson({
        'id': 5,
        'reporter_id': 9,
        'item_id': 12,
        'reason': 'spam',
        'description': 'looks fake',
        'status': 'under_review',
        'admin_note': 'checking',
        'created_at': '2026-01-02T10:00:00.000Z',
        'updated_at': '2026-01-03T10:00:00.000Z',
      });

      expect(report.id, 5);
      expect(report.reporterId, 9);
      expect(report.itemId, 12);
      expect(report.claimId, isNull);
      expect(report.reason, ReportReason.spam);
      expect(report.status, ReportStatus.under_review);
      expect(report.description, 'looks fake');
      expect(report.adminNote, 'checking');
      expect(report.createdAt, isNotNull);
      expect(report.updatedAt, isNotNull);
    });

    test('parses camelCase and string ids', () {
      final report = Report.fromJson({
        'id': '7',
        'reporterId': '3',
        'claimId': '4',
        'reason': 'fake',
        'status': 'resolved',
      });

      expect(report.id, 7);
      expect(report.reporterId, 3);
      expect(report.claimId, 4);
      expect(report.itemId, isNull);
    });

    test('accepts enum instances directly for reason and status', () {
      final report = Report.fromJson({
        'id': 1,
        'reporterId': 1,
        'reason': ReportReason.wrong_owner,
        'status': ReportStatus.rejected,
      });
      expect(report.reason, ReportReason.wrong_owner);
      expect(report.status, ReportStatus.rejected);
    });

    test('tolerates invalid dates by returning null', () {
      final report = Report.fromJson({
        'id': 1,
        'reporterId': 1,
        'reason': 'other',
        'status': 'pending',
        'created_at': 'not-a-date',
      });
      expect(report.createdAt, isNull);
    });

    test('throws when required id is missing', () {
      expect(
        () => Report.fromJson({'reporterId': 1, 'reason': 'spam', 'status': 'pending'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Report.toJson', () {
    test('round-trips through fromJson preserving key fields', () {
      final original = Report(
        id: 2,
        reporterId: 8,
        itemId: 4,
        reason: ReportReason.fake,
        status: ReportStatus.pending,
        description: 'desc',
      );

      final json = original.toJson();
      expect(json['reason'], 'fake');
      expect(json['status'], 'pending');
      expect(json['reporter_id'], 8);

      final restored = Report.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.reason, original.reason);
      expect(restored.status, original.status);
      expect(restored.description, original.description);
    });
  });
}
