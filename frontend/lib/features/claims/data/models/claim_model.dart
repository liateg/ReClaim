class ClaimModel {
  final int id;
  final int itemId;
  final int claimantId;
  final String answerAttempt;
  final String status;
  final String? reviewNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClaimModel({
    required this.id,
    required this.itemId,
    required this.claimantId,
    required this.answerAttempt,
    required this.status,
    this.reviewNote,
    this.createdAt,
    this.updatedAt,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
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
    final itemVal = json['itemId'] ?? json['item_id'];
    final claimantVal = json['claimantId'] ?? json['claimant_id'];
    final createdVal = json['createdAt'] ?? json['created_at'];
    final updatedVal = json['updatedAt'] ?? json['updated_at'];

    return ClaimModel(
      id: parseInt(idVal),
      itemId: parseInt(itemVal),
      claimantId: parseInt(claimantVal),
      answerAttempt:
          (json['answerAttempt'] ?? json['answer_attempt'])?.toString() ?? '',
      status: (json['status'] ?? '').toString(),
      reviewNote: (json['reviewNote'] ?? json['review_note']) as String?,
      createdAt: parse(createdVal?.toString()),
      updatedAt: parse(updatedVal?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'claimant_id': claimantId,
        'answer_attempt': answerAttempt,
        'status': status,
        'review_note': reviewNote,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
