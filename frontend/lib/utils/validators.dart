/// Reusable input validation helpers shared across auth and form screens.
///
/// Each validator returns `null` when the value is valid, or a human readable
/// error message when it is not. This mirrors the contract expected by
/// Flutter's `TextFormField.validator`.
class Validators {
  Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Returns true when [value] looks like a syntactically valid email address.
  static bool isValidEmail(String? value) {
    if (value == null) return false;
    return _emailRegex.hasMatch(value.trim());
  }

  /// Validates a required, non-empty field.
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  /// Validates an email field.
  static String? email(String? value) {
    final requiredError = required(value, field: 'Email');
    if (requiredError != null) return requiredError;
    if (!isValidEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates a password against a minimum length.
  static String? password(String? value, {int minLength = 6}) {
    final requiredError = required(value, field: 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that [confirmation] matches [original].
  static String? confirmPassword(String? original, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }
    if (original != confirmation) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a display name against a minimum length.
  static String? name(String? value, {int minLength = 2}) {
    final requiredError = required(value, field: 'Name');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    return null;
  }
}
