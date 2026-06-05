import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/error_banner.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the message and an error icon', (tester) async {
    await tester.pumpWidget(host(const ErrorBanner(message: 'Network down')));
    expect(find.text('Network down'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('shows a retry button only when a callback is given',
      (tester) async {
    await tester.pumpWidget(host(const ErrorBanner(message: 'Oops')));
    expect(find.text('Retry'), findsNothing);

    var retried = 0;
    await tester.pumpWidget(host(ErrorBanner(
      message: 'Oops',
      onRetry: () => retried++,
    )));
    await tester.tap(find.text('Retry'));
    expect(retried, 1);
  });
}
