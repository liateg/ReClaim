import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../data/services/claim_service.dart';
import 'claim_notifier.dart';
import 'claim_state.dart';

final dioClientProvider = Provider((ref) => DioClient().dio);

final claimServiceProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return ClaimService(dio);
});

final claimProvider = StateNotifierProvider<ClaimNotifier, ClaimState>((ref) {
  final service = ref.watch(claimServiceProvider);
  return ClaimNotifier(service);
});
