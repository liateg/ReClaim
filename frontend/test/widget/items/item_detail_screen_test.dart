import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/claims/Riverpod/claims_provider.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/features/items/presentation/screens/item_detail_screen.dart'
    as item_pages;

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('shows a loading spinner while the item loads', (tester) async {
    await tester.pumpWidget(wrapApp(
      const item_pages.ClaimDetailScreen(claimId: '1'),
      overrides: [
        itemByIdProvider.overrideWith(
          (ref, id) => Completer<Map<String, dynamic>?>().future,
        ),
        claimsListProvider.overrideWith(
          (ref) => Completer<List<dynamic>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.byType(item_pages.ClaimDetailScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a not-found message when the item is null',
      (tester) async {
    await tester.pumpWidget(wrapApp(
      const item_pages.ClaimDetailScreen(claimId: '1'),
      overrides: [
        itemByIdProvider.overrideWith((ref, id) async => null),
        claimsListProvider.overrideWith((ref) async => <dynamic>[]),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('Item not found'), findsOneWidget);
  });
}
