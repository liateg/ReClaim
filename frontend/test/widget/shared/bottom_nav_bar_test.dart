import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/navigation/app_bottom_nav.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(bottomNavigationBar: child));

  testWidgets('renders user destinations', (tester) async {
    await tester.pumpWidget(host(AppNavigationBar(
      currentIndex: 0,
      onDestinationSelected: (_) {},
    )));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Items'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('renders admin destinations in admin mode', (tester) async {
    await tester.pumpWidget(host(AppNavigationBar(
      currentIndex: 0,
      adminMode: true,
      onDestinationSelected: (_) {},
    )));

    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('REPORTS'), findsOneWidget);
  });

  testWidgets('reports the selected index', (tester) async {
    int? selected;
    await tester.pumpWidget(host(AppNavigationBar(
      currentIndex: 0,
      onDestinationSelected: (i) => selected = i,
    )));

    await tester.tap(find.text('My Items'));
    expect(selected, 2);
  });
}
