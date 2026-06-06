import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/reports/presentation/screens/feedback_submitted_success.dart';

import '../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the feedback success confirmation', (tester) async {
    await tester.pumpWidget(wrapApp(const FeedbackSuccessScreen()));
    await tester.pump();

    expect(find.text('Feedback Submitted'), findsOneWidget);
    expect(find.text('Back to Claims'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}
