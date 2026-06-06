import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the login form', (tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(CustomTextField), findsNWidgets(2));
    expect(find.widgetWithText(CustomButton, 'Sign In'), findsOneWidget);
  });

  testWidgets('shows validation errors when submitting empty fields',
      (tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));

    await tester.tap(find.widgetWithText(CustomButton, 'Sign In'));
    await tester.pump();

    expect(find.text('Please fill in all fields'), findsOneWidget);
  });
}
