import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/claims_service.dart';

final claimsServiceProvider = Provider((ref) => ClaimsService());

final claimsListProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.watch(claimsServiceProvider);
  return service.getClaims();
});

final claimProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, claimId) async {
    final service = ref.watch(claimsServiceProvider);
    return service.getClaimById(claimId);
  },
);
