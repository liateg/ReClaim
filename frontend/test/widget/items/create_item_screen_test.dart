import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/items/presentation/screens/create_item_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('builds the create-item form without errors', (tester) async {
    await tester.pumpWidget(wrapApp(const CreateItemScreen()));
    await tester.pump();

    expect(find.byType(CreateItemScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(TextField), findsWidgets);
  });
}
