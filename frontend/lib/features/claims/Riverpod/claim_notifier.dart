import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/claim_model.dart';
import '../data/services/claim_service.dart';
import '../enum/claim_status.dart';
import 'claim_state.dart';

class ClaimNotifier extends StateNotifier<ClaimState> {
  final ClaimService _service;

  ClaimNotifier(this._service) : super(ClaimState(claims: [])) {
    loadClaims();
  }

  Future<void> loadClaims() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final claims = await _service.getClaims();
      state = state.copyWith(claims: claims, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addClaim(Claim claim) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final newClaim = await _service.createClaim(claim);
      state = state.copyWith(
        claims: [...state.claims, newClaim],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> removeClaim(String id) async {
    try {
      print('DEBUG: Attempting to remove claim ID: $id');
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _service.deleteClaim(id);
      print('DEBUG: Claim $id removed from server successfully');
      state = state.copyWith(
        claims: state.claims.where((c) => c.id != id).toList(),
        isLoading: false,
      );
      if (state.selectedClaim?.id == id) {
        clearSelectedClaim();
      }
    } catch (e) {
      print('DEBUG: Error removing claim: $e');
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to delete: ${e.toString()}');
    }
  }

  Future<void> updateClaim(Claim updatedClaim) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final result = await _service.updateClaim(updatedClaim);
      state = state.copyWith(
        claims: state.claims.map((c) => c.id == result.id ? result : c).toList(),
        isLoading: false,
      );
      if (state.selectedClaim?.id == result.id) {
        state = state.copyWith(selectedClaim: result);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> approveClaim(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final result = await _service.approveClaim(id);
      state = state.copyWith(
        claims: state.claims.map((c) => c.id == result.id ? result : c).toList(),
        isLoading: false,
      );
      if (state.selectedClaim?.id == result.id) {
        state = state.copyWith(selectedClaim: result);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> withdrawClaim(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final claim = state.claims.firstWhere((c) => c.id == id);
      final updatedClaim = claim.copyWith(status: ClaimStatus.withdrawn);
      final result = await _service.updateClaim(updatedClaim);
      state = state.copyWith(
        claims: state.claims.map((c) => c.id == result.id ? result : c).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteClaim(String id) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _service.deleteClaim(id);
      state = state.copyWith(
        claims: state.claims.where((c) => c.id != id).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
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
  Future<String> uploadImage(String filePath) async {
    return await _service.uploadImage(filePath);
  }
}
