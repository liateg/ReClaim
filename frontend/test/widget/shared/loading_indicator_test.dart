import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/loading_indicator.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('shows a progress indicator', (tester) async {
    await tester.pumpWidget(host(const LoadingIndicator()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an optional message', (tester) async {
    await tester.pumpWidget(host(const LoadingIndicator(message: 'Loading…')));
    expect(find.text('Loading…'), findsOneWidget);
  });

  testWidgets('omits text when no message provided', (tester) async {
    await tester.pumpWidget(host(const LoadingIndicator()));
    expect(find.byType(Text), findsNothing);
  });
}
