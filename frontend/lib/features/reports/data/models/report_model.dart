class ReportModel {
  final int id;
  final int reporterId;
  final int? itemId;
  final int? claimId;
  final String reason;
  final String? description;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportModel({
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

  factory ReportModel.fromJson(Map<String, dynamic> json) {
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

    return ReportModel(
      id: parseInt(idVal),
      reporterId: parseInt(reporterVal),
      itemId: itemVal == null ? null : parseInt(itemVal),
      claimId: claimVal == null ? null : parseInt(claimVal),
      reason: (json['reason'] ?? '').toString(),
      description: (json['description'] ?? null) as String?,
      status: (json['status'] ?? '').toString(),
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
        'reason': reason,
        'description': description,
        'status': status,
        'admin_note': adminNote,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
