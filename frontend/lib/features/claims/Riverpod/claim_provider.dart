import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/claims/Riverpod/claim_notifier.dart';
import 'package:frontend/features/claims/Riverpod/claim_state.dart';

final claimProvider = StateNotifierProvider<ClaimNotifier, ClaimState>((ref) {
  return ClaimNotifier();
});
