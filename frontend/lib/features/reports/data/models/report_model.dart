import 'package:flutter/material.dart';

enum ReportReason {
  fake,
  spam,
  wrong_owner,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.fake:
        return 'Fake Item';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.wrong_owner:
        return 'Wrong Owner';
      case ReportReason.other:
        return 'Other';
    }
  }

  static ReportReason fromString(String value) {
    return ReportReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportReason.other,
    );
  }
}

enum ReportStatus {
  pending,
  under_review,
  resolved,
  rejected;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.under_review:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.under_review:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

class Report {
  final int id;
  final int reporterId;
  final int? itemId;
  final int? claimId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Report({
    required this.id,
    required this.reporterId,
    this.itemId,
    this.claimId,
    required this.reason,
    this.description,
    required this.status,
    this.adminNote,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    int parseInt(dynamic v) {
      if (v == null) throw FormatException('Missing integer value');
      if (v is int) return v;
      final s = v.toString();
      return int.parse(s);
    }

    final idVal = json['id'] ?? json['Id'];
    final reporterVal = json['reporterId'] ?? json['reporter_id'];
    final itemVal = json['itemId'] ?? json['item_id'];
    final claimVal = json['claimId'] ?? json['claim_id'];
    final createdVal = json['createdAt'] ?? json['created_at'];
    final updatedVal = json['updatedAt'] ?? json['updated_at'];

    final reasonValue = json['reason'];
    final statusValue = json['status'];

    return Report(
      id: parseInt(idVal),
      reporterId: parseInt(reporterVal),
      itemId: itemVal == null ? null : parseInt(itemVal),
      claimId: claimVal == null ? null : parseInt(claimVal),
      reason: reasonValue is ReportReason
          ? reasonValue
          : ReportReason.fromString(reasonValue?.toString() ?? ''),
      description: (json['description'] ?? null) as String?,
      status: statusValue is ReportStatus
          ? statusValue
          : ReportStatus.fromString(statusValue?.toString() ?? ''),
      adminNote: (json['adminNote'] ?? json['admin_note']) as String?,
      createdAt: parse(createdVal?.toString()),
      updatedAt: parse(updatedVal?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporter_id': reporterId,
        'item_id': itemId,
        'claim_id': claimId,
        'reason': reason.name,
        'description': description,
        'status': status.name,
        'admin_note': adminNote,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
