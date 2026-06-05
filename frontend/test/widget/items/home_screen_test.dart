import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/features/items/presentation/screens/claim_item_screen.dart'
    as discovery;

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the discovery screen in a loading state',
      (tester) async {
    await tester.pumpWidget(wrapApp(
      const discovery.ClaimsScreen(),
      overrides: [
        itemsListProvider.overrideWith(
          (ref) => Completer<List<Map<String, dynamic>>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.byType(discovery.ClaimsScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders an empty discovery list', (tester) async {
    await tester.pumpWidget(wrapApp(
      const discovery.ClaimsScreen(),
      overrides: [
        itemsListProvider.overrideWith(
          (ref) async => <Map<String, dynamic>>[],
        ),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(discovery.ClaimsScreen), findsOneWidget);
  });
}
