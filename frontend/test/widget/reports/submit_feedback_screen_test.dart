import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/reports/presentation/screens/submit_feedback_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('builds the feedback form', (tester) async {
    await tester.pumpWidget(wrapApp(
      const SubmitFeedbackScreen(itemId: '1'),
    ));
    await tester.pump();

    expect(find.byType(SubmitFeedbackScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
