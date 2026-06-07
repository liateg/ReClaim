// UI-driven registration flow (on emulator).
//
// Drives: splash -> "Get Started" -> register screen -> tap "Create Account"
// with empty fields (visible validation error) -> fill in the form fields.
//
// It intentionally does NOT submit a real registration, so it never creates a
// user on your backend. It only needs a booted emulator/device (no backend
// call is required for the validation step).
//
// Run with:
//   flutter test integration_test/register_flow_test.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/shared/widgets/custom_button.dart';

import 'flow_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('register flow: splash -> register -> validate -> fill form',
      (tester) async {
    await AppSession.signOut();

    await tester.pumpWidget(const ProviderScope(child: ReClaimApp()));
    await logStep(tester, 'App launched — splash screen visible');

    // 1) Tap "Get Started" to open the registration screen.
    await tester.tap(find.textContaining('Get Started'));
    await logStep(tester, 'Tapped "Get Started" — navigating to register');
    expect(find.byType(CustomButton), findsWidgets);

    // 2) Submit empty to trigger validation.
    final createButton = find.widgetWithText(CustomButton, 'Create Account');
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await logStep(tester, 'Tapped "Create Account" with empty fields');
    expect(find.text('Please fill in all fields'), findsOneWidget);
    debugPrint('UI RESULT -> validation error shown as expected');

    // 3) Fill in the four fields (name, email, password, confirm).
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(0), 'Test User');
    await logStep(tester, 'Entered full name');
    await tester.enterText(fields.at(1), 'newuser@example.com');
    await logStep(tester, 'Entered email');
    await tester.enterText(fields.at(2), 'Password123!');
    await logStep(tester, 'Entered password');
    await tester.enterText(fields.at(3), 'Password123!');
    await logStep(tester, 'Entered password confirmation');

    debugPrint('REGISTER FORM FLOW COMPLETED (not submitted)');
  });
}
