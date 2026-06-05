import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/reports/data/models/report_model.dart';
import 'package:frontend/features/reports/Riverpod/report_provider.dart';
import 'package:frontend/features/reports/reports_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('shows the app bar and a loading spinner', (tester) async {
    await tester.pumpWidget(wrapApp(
      const ReportsScreen(),
      overrides: [
        myReportsProvider.overrideWith(
          (ref) => Completer<List<Report>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.text('My Reports'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty message when there are no reports',
      (tester) async {
    await tester.pumpWidget(wrapApp(
      const ReportsScreen(),
      overrides: [
        myReportsProvider.overrideWith((ref) async => <Report>[]),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('No reports yet'), findsOneWidget);
  });
}
