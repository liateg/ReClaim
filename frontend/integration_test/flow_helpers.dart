// Shared helpers for the UI-driven integration flows.
//
// Not a test file itself (no `_test` suffix), so the integration runner won't
// execute it directly — it's imported by the *_test.dart flow files.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/shared/widgets/custom_button.dart';

/// Default backend credentials (override with --dart-define).
const testEmail =
    String.fromEnvironment('TEST_EMAIL', defaultValue: 'admin@example.com');
const testPassword =
    String.fromEnvironment('TEST_PASSWORD', defaultValue: 'TestPass123!');

/// Pause after each step so the action is visible on the emulator. Set to
/// Duration.zero for maximum speed.
const stepPause = Duration(milliseconds: 500);

/// Logs a step, settles the UI, then lingers briefly for visibility.
Future<void> logStep(WidgetTester tester, String message) async {
  debugPrint('UI STEP -> $message');
  await tester.pumpAndSettle();
  await Future<void>.delayed(stepPause);
}

/// Pumps in fixed slices instead of pumpAndSettle. Use for screens that keep a
/// spinner/animation running (where pumpAndSettle would hang).
Future<void> pumpFor(
  WidgetTester tester, {
  Duration total = const Duration(seconds: 2),
  Duration slice = const Duration(milliseconds: 200),
}) async {
  var elapsed = Duration.zero;
  while (elapsed < total) {
    await tester.pump(slice);
    elapsed += slice;
  }
}

/// Drives splash -> login -> enter credentials -> tap Sign In, then waits until
/// the login screen is left (navigated in) or times out. Returns true on
/// success. Assumes the app was just pumped and is on the splash screen.
Future<bool> loginViaUi(
  WidgetTester tester, {
  String email = testEmail,
  String password = testPassword,
}) async {
  await logStep(tester, 'Splash visible — tapping "Sign In"');
  await tester.tap(find.text('Sign In'));
  await logStep(tester, 'Login screen — entering credentials');

  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await logStep(tester, 'Submitting login for $email');

  final signIn = find.widgetWithText(CustomButton, 'Sign In');
  await tester.ensureVisible(signIn);
  await tester.pumpAndSettle();
  await tester.tap(signIn);

  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 300));
    final sawSnackbar = find.text('Welcome back!').evaluate().isNotEmpty;
    final leftLogin = find.text('Welcome Back').evaluate().isEmpty;
    if (sawSnackbar || leftLogin) return true;
  }
  return false;
}

/// Navigates to [path] via GoRouter using a context from the running tree.
/// This works regardless of whether the user is in user or admin mode (the
/// bottom-nav destinations differ between the two).
Future<void> goTo(WidgetTester tester, String path) async {
  final context = tester.element(find.byType(Navigator).first);
  GoRouter.of(context).go(path);
  await pumpFor(tester, total: const Duration(seconds: 2));
  await Future<void>.delayed(stepPause);
}

/// Waits (in slices) until [finder] matches, or returns false on timeout.
Future<bool> waitFor(
  WidgetTester tester,
  Finder finder, {
  int tries = 25,
  Duration slice = const Duration(milliseconds: 300),
}) async {
  for (var i = 0; i < tries; i++) {
    await tester.pump(slice);
    if (finder.evaluate().isNotEmpty) return true;
  }
  return false;
}
