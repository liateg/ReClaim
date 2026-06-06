import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:frontend/features/auth/riverpod/auth_provider.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the registration form', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(wrapApp(
        const RegisterScreen(),
        overrides: [authProvider.overrideWith((ref) => false)],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    // The heading and the submit button both read "Create Account".
    expect(find.text('Create Account'), findsNWidgets(2));
    expect(find.widgetWithText(CustomButton, 'Create Account'), findsOneWidget);
    expect(find.byType(CustomTextField), findsNWidgets(4));
  });

  testWidgets('validates empty submission', (tester) async {
    // The auth FutureProvider only resolves on the real event loop, so drive
    // the first build inside runAsync to let it settle out of its loading
    // state and reveal the submit button.
    await tester.runAsync(() async {
      await tester.pumpWidget(wrapApp(
        const RegisterScreen(),
        overrides: [authProvider.overrideWith((ref) => false)],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    final button = find.widgetWithText(CustomButton, 'Create Account');
    expect(button, findsOneWidget);

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Please fill in all fields'), findsOneWidget);
  });
}
