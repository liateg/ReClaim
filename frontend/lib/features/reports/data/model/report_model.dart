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
  final String id;
  final String reporterId;
  final String? itemId;
  final String? claimId;
  final ReportReason reason;
  final String? description;
  final ReportStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.reporterId,
    this.itemId,
    this.claimId,
    required this.reason,
    this.description,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      reporterId: json['reporter_id'].toString(),
      itemId: json['item_id']?.toString(),
      claimId: json['claim_id']?.toString(),
      reason: ReportReason.fromString(json['reason']),
      description: json['description'],
      status: ReportStatus.fromString(json['status']),
      adminNote: json['admin_note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'item_id': itemId,
      'claim_id': claimId,
      'reason': reason.name,
      'description': description,
      'status': status.name,
      'admin_note': adminNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? itemId,
    String? claimId,
    ReportReason? reason,
    String? description,
    ReportStatus? status,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      itemId: itemId ?? this.itemId,
      claimId: claimId ?? this.claimId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
