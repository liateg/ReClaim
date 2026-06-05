import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/empty_state_widget.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders title and subtitle', (tester) async {
    await tester.pumpWidget(host(const EmptyStateWidget(
      title: 'No claims yet',
      subtitle: 'Your claims will appear here',
    )));

    expect(find.text('No claims yet'), findsOneWidget);
    expect(find.text('Your claims will appear here'), findsOneWidget);
  });

  testWidgets('shows the default icon', (tester) async {
    await tester.pumpWidget(host(const EmptyStateWidget(title: 'Empty')));
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('renders an action button and fires its callback',
      (tester) async {
    var pressed = 0;
    await tester.pumpWidget(host(EmptyStateWidget(
      title: 'Empty',
      actionLabel: 'Explore',
      onAction: () => pressed++,
    )));

    expect(find.text('Explore'), findsOneWidget);
    await tester.tap(find.text('Explore'));
    expect(pressed, 1);
  });

  testWidgets('hides the action when no callback supplied', (tester) async {
    await tester.pumpWidget(host(const EmptyStateWidget(
      title: 'Empty',
      actionLabel: 'Explore',
    )));
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
