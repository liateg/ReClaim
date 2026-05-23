import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:frontend/features/claims/data/model/claim_model.dart';
import 'package:frontend/features/claims/data/mock/mock_claims.dart';
import 'package:frontend/features/claims/Riverpod/claim_state.dart';

class ClaimNotifier extends StateNotifier<ClaimState> {
  ClaimNotifier() : super(ClaimState(claims: mockClaims));

  void addClaim(Claim claim) {
    state = state.copyWith(
      claims: [...state.claims, claim],
    );
  }

  void removeClaim(String id) {
    state = state.copyWith(
      claims: state.claims.where((c) => c.id != id).toList(),
    );
    if (state.selectedClaim?.id == id) {
      clearSelectedClaim();
    }
  }

  void updateClaim(Claim updatedClaim) {
    state = state.copyWith(
      claims: state.claims.map((c) => c.id == updatedClaim.id ? updatedClaim : c).toList(),
    );
    if (state.selectedClaim?.id == updatedClaim.id) {
      state = state.copyWith(selectedClaim: updatedClaim);
    }
  }

  void selectClaim(Claim claim) {
    state = state.copyWith(selectedClaim: claim);
  }

  void clearSelectedClaim() {
    state = state.copyWith(clearSelectedClaim: true);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}
