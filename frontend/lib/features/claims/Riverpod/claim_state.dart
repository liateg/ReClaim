import '../data/model/claim_model.dart';

class ClaimState {
  final List<Claim> claims;
  final Claim? selectedClaim;
  final bool isLoading;
  final String? errorMessage;

  ClaimState({
    this.claims = const [],
    this.selectedClaim,
    this.isLoading = false,
    this.errorMessage,
  });

  ClaimState copyWith({
    List<Claim>? claims,
    Claim? selectedClaim,
    bool? isLoading,
    String? errorMessage,
    bool clearSelectedClaim = false,
    bool clearErrorMessage = false,
  }) {
    return ClaimState(
      claims: claims ?? this.claims,
      selectedClaim: clearSelectedClaim ? null : (selectedClaim ?? this.selectedClaim),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClaimState &&
          runtimeType == other.runtimeType &&
          claims == other.claims &&
          selectedClaim == other.selectedClaim &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      claims.hashCode ^
      selectedClaim.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode;
}
