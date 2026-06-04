import 'package:dio/dio.dart';
import 'package:frontend/core/session/services/auth_service.dart';

import '../../claims/data/model/claim_model.dart' as ui_claim;
import '../../claims/data/models/claim_model.dart' as api_claim;
import '../../claims/data/claims_service.dart';
import '../../claims/enum/claim_status.dart';
import '../../items/data/items_service.dart';
import '../../items/data/models/item_model.dart';

class AdminUserSummary {
  final int id;
  final String fullName;
  final String email;
  final String role;

  const AdminUserSummary({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    return AdminUserSummary(
      id: idValue is int ? idValue : int.parse(idValue.toString()),
      fullName: json['fullName']?.toString() ?? 'Unknown user',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }
}

class AdminClaimRecord {
  final api_claim.ClaimModel claim;
  final ItemModel item;
  final AdminUserSummary? claimant;

  const AdminClaimRecord({
    required this.claim,
    required this.item,
    required this.claimant,
  });

  ui_claim.Claim toUiClaim() {
    return ui_claim.Claim(
      id: claim.id.toString(),
      title: item.title,
      category: item.category,
      description: item.description,
      location: item.location,
      status: _statusFromApi(claim.status),
      imageUrl: item.imageUrl.isEmpty ? null : item.imageUrl,
      date: _parseDateTime(claim.createdAt?.toIso8601String()) ??
          _parseDateTime(item.createdAt) ??
          DateTime.now(),
    );
  }

  String get reviewCode => 'SH-${98 + claim.id}';

  String get itemIdBadge => item.id;

  String get recoveredNote =>
      'Reported recovered near: ${item.location}. Please verify claimant evidence before approving.';

  List<String> get tags => [
        item.category,
        claim.status,
        if (claim.reviewNote != null && claim.reviewNote!.trim().isNotEmpty)
          claim.reviewNote!.trim(),
      ];

  String get claimantInitials => _initials(claimant?.fullName ?? item.title);

  String get claimantName => claimant?.fullName ?? 'User #${claim.claimantId}';

  String get claimantEmail => claimant?.email.isNotEmpty == true
      ? claimant!.email
      : 'user.${claim.claimantId}@unknown';

  String get verifiedIdReference =>
      '#${claimant?.id ?? claim.claimantId}-${item.id}';

  String get evidenceQuestion1 => item.verificationQuestion.isNotEmpty
      ? item.verificationQuestion
      : 'VERIFICATION QUESTION';

  String get evidenceAnswer1 => claim.answerAttempt.isNotEmpty
      ? claim.answerAttempt
      : 'No answer attempt submitted.';

  String get evidenceQuestion2 => 'EXPECTED ANSWER';

  String get evidenceAnswer2 => item.verificationAnswer.isNotEmpty
      ? item.verificationAnswer
      : 'No stored verification answer available.';

  String get securityProtocolText =>
      'Verify university ID against registrar records before possession transfer. Retain review notes for audits.';
}

class AdminClaimsRepository {
  AdminClaimsRepository({ClaimsService? claimsService, ItemsService? itemsService})
      : _claimsService = claimsService ?? ClaimsService(),
        _itemsService = itemsService ?? ItemsService();

  final ClaimsService _claimsService;
  final ItemsService _itemsService;
  final Dio _dio = Dio()..options.baseUrl = AuthService.baseUrl;

  Future<List<AdminClaimRecord>> getClaims({bool forceRefresh = true}) async {
    final results = await Future.wait([
      _claimsService.getClaims(forceRefresh: forceRefresh),
      _itemsService.getAdminItems(forceRefresh: forceRefresh),
      _loadUsers(),
    ]);

    final List<dynamic> claimsRaw = results[0];
    final items = results[1] as List<ItemModel>;
    final users = results[2] as List<AdminUserSummary>;

    final itemsById = {
      for (final item in items) item.id: item,
    };
    final usersById = {
      for (final user in users) user.id.toString(): user,
    };

    final records = <AdminClaimRecord>[];
    for (final raw in claimsRaw) {
      if (raw is! Map) continue;
      final claim = api_claim.ClaimModel.fromJson(
        Map<String, dynamic>.from(raw),
      );
      final item = itemsById[claim.itemId.toString()] ?? _fallbackItem(claim);
      records.add(
        AdminClaimRecord(
          claim: claim,
          item: item,
          claimant: usersById[claim.claimantId.toString()],
        ),
      );
    }

    return records;
  }

  Future<AdminClaimRecord?> getClaimById(String id,
      {bool forceRefresh = true}) async {
    final claims = await getClaims(forceRefresh: forceRefresh);
    for (final record in claims) {
      if (record.claim.id.toString() == id) {
        return record;
      }
    }
    return null;
  }

  Future<List<AdminUserSummary>> _loadUsers() async {
    final token = await AuthService().getToken();
    final res = await _dio.get(
      '/users',
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );

    final dataRaw = res.data;
    final list = dataRaw is List
        ? dataRaw
        : (dataRaw is Map<String, dynamic> ? dataRaw['users'] : null);

    if (list is! List) {
      return const [];
    }

    return list
        .whereType<Map>()
        .map((user) => AdminUserSummary.fromJson(
              Map<String, dynamic>.from(user),
            ))
        .toList();
  }

  ItemModel _fallbackItem(api_claim.ClaimModel claim) {
    return ItemModel(
      id: claim.itemId.toString(),
      title: 'Claim #${claim.id}',
      location: 'Unknown location',
      description: claim.reviewNote ?? 'No item details available.',
      category: 'Other',
      categoryId: null,
      status: 'claimed',
      dateFound: '',
      verificationQuestion: '',
      verificationAnswer: '',
      imageUrl: '',
      hiddenDetails: null,
      postedBy: null,
      createdAt: claim.createdAt?.toIso8601String(),
      updatedAt: claim.updatedAt?.toIso8601String(),
    );
  }
}

ClaimStatus _statusFromApi(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return ClaimStatus.approved;
    case 'rejected':
    case 'withdrawn':
      return ClaimStatus.rejected;
    case 'pending':
    default:
      return ClaimStatus.pending;
  }
}

String _initials(String value) {
  final parts = value.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  final list = parts.toList();
  if (list.isEmpty) return 'NA';
  if (list.length == 1) {
    final word = list.first;
    return word.length >= 2 ? word.substring(0, 2).toUpperCase() : '${word}X'.toUpperCase();
  }
  return '${list[0][0]}${list[1][0]}'.toUpperCase();
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}