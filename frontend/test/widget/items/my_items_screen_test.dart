import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/items/Riverpod/items_provider.dart';
import 'package:frontend/features/items/presentation/screens/admin_item_list_screen.dart';

import '../../helpers/test_helpers.dart';

/// "My Items" / inventory list screen, backed by the admin items provider.
void main() {
  testWidgets('renders the inventory list in a loading state', (tester) async {
    await tester.pumpWidget(wrapApp(
      const AdminItemListScreen(),
      overrides: [
        adminItemsListProvider.overrideWith(
          (ref) => Completer<List<Map<String, dynamic>>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.byType(AdminItemListScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders an empty inventory list', (tester) async {
    await tester.pumpWidget(wrapApp(
      const AdminItemListScreen(),
      overrides: [
        adminItemsListProvider.overrideWith(
          (ref) async => <Map<String, dynamic>>[],
        ),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(AdminItemListScreen), findsOneWidget);
  });
}
