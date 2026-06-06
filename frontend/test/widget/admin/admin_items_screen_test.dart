import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/admin_items_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the items management placeholder', (tester) async {
    await tester.pumpWidget(wrapApp(const AdminItemsScreen()));
    await tester.pump();

    expect(find.text('Lost Items Inventory'), findsOneWidget);
    expect(find.text('Items Management'), findsOneWidget);
  });
}
