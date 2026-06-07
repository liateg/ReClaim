// UI-driven on-emulator integration test.
//
// This launches the REAL app on the connected emulator/device and visibly
// drives the UI: splash -> tap "Sign In" -> login screen -> type credentials
// -> tap the Sign In button -> verify it navigates in. Every step is logged to
// the console so you can follow along, and a short pause after each step makes
// the taps visible on the emulator (kept small so the run stays fast).
//
// Prerequisites:
//   1. Backend running on the host at port 3000 (reachable via 10.0.2.2 on the
//      Android emulator).
//   2. A booted emulator/device.
//   3. Valid credentials (defaults below, or override with --dart-define).
//
// Run with:
//   flutter test integration_test/login_flow_test.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/shared/widgets/custom_button.dart';

const _email =
    String.fromEnvironment('TEST_EMAIL', defaultValue: 'admin@example.com');
const _password =
    String.fromEnvironment('TEST_PASSWORD', defaultValue: 'TestPass123!');

// How long to linger after each step so the action is visible on screen.
// Lower this to 0 for maximum speed.
const _stepPause = Duration(milliseconds: 500);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Logs the step, settles the UI, then pauses briefly for visibility.
  Future<void> step(WidgetTester tester, String message) async {
    debugPrint('UI STEP -> $message');
    await tester.pumpAndSettle();
    await Future<void>.delayed(_stepPause);
  }

  testWidgets('login flow: splash -> login -> sign in', (tester) async {
    // Start from a clean, logged-out state.
    await AppSession.signOut();

    await tester.pumpWidget(const ProviderScope(child: ReClaimApp()));
    await step(tester, 'App launched — splash screen visible');
    expect(find.textContaining('Get Started'), findsOneWidget);

    // 1) Tap the "Sign In" link on the splash screen.
    await tester.tap(find.text('Sign In'));
    await step(tester, 'Tapped "Sign In" on splash — navigating to login');
    expect(find.text('Welcome Back'), findsOneWidget);

    // 2) Type the email into the first field.
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), _email);
    await step(tester, 'Entered email: $_email');

    // 3) Type the password into the second field.
    await tester.enterText(fields.at(1), _password);
    await step(tester, 'Entered password');

    // 4) Tap the Sign In button.
    final signInButton = find.widgetWithText(CustomButton, 'Sign In');
    await tester.ensureVisible(signInButton);
    await tester.pumpAndSettle();
    debugPrint('UI STEP -> Tapping "Sign In" to submit to the backend');
    await tester.tap(signInButton);

    // The home screen keeps a spinner running, so pumpAndSettle would hang.
    // Instead pump in slices until we either see the success snackbar or the
    // login screen is gone (navigation happened).
    var navigatedIn = false;
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final sawSnackbar = find.text('Welcome back!').evaluate().isNotEmpty;
      final leftLogin = find.text('Welcome Back').evaluate().isEmpty;
      if (sawSnackbar || leftLogin) {
        navigatedIn = true;
        break;
      }
    }

    final sawError = find.text('Please fill in all fields').evaluate().isNotEmpty;
    debugPrint('UI RESULT -> navigatedIn=$navigatedIn, validationError=$sawError');

    expect(
      navigatedIn,
      isTrue,
      reason: 'After a successful sign in the app should navigate away from '
          'the login screen (or show the "Welcome back!" snackbar). If this '
          'fails, check the backend is running and the credentials are valid.',
    );
    debugPrint('LOGIN FLOW COMPLETED SUCCESSFULLY');
  });
}
