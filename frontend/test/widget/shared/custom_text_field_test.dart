import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the label and accepts input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(host(CustomTextField(
      controller: controller,
      label: 'EMAIL',
      hint: 'you@example.com',
    )));

    expect(find.text('EMAIL'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'hi@there.com');
    expect(controller.text, 'hi@there.com');
  });

  testWidgets('shows an error message when provided', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(host(CustomTextField(
      controller: controller,
      label: 'EMAIL',
      errorText: 'Invalid email',
    )));

    expect(find.text('Invalid email'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('obscure fields show a visibility toggle', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(host(CustomTextField(
      controller: controller,
      label: 'PASSWORD',
      obscureText: true,
    )));

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
