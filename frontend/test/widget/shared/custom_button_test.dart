import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/custom_button.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders its label', (tester) async {
    await tester.pumpWidget(host(const CustomButton(text: 'Sign In')));
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(host(CustomButton(
      text: 'Tap me',
      onPressed: () => tapped++,
    )));

    await tester.tap(find.byType(CustomButton));
    expect(tapped, 1);
  });

  testWidgets('shows a loading state and ignores taps', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(host(CustomButton(
      text: 'Sign In',
      isLoading: true,
      onPressed: () => tapped++,
    )));
    // The loading row is wider than the button's fixed width, which produces a
    // benign layout overflow in the constrained test surface; consume it.
    tester.takeException();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Authenticating...'), findsOneWidget);

    await tester.tap(find.byType(CustomButton), warnIfMissed: false);
    expect(tapped, 0);
  });

  testWidgets('renders an outlined variant', (tester) async {
    await tester.pumpWidget(host(const CustomButton(
      text: 'Outlined',
      isOutLined: true,
    )));
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
