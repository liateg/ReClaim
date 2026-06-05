import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/reports/data/models/report_model.dart';
import 'package:frontend/features/reports/Riverpod/report_provider.dart';
import 'package:frontend/features/reports/presentation/screens/adminPages/admin_reports_all_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('shows the title and a loading spinner', (tester) async {
    await tester.pumpWidget(wrapApp(
      const AdminReportsAllScreen(),
      overrides: [
        allReportsProvider.overrideWith(
          (ref) => Completer<List<Report>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.text('All Reports'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders with an empty report list', (tester) async {
    await tester.pumpWidget(wrapApp(
      const AdminReportsAllScreen(),
      overrides: [
        allReportsProvider.overrideWith((ref) async => <Report>[]),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(AdminReportsAllScreen), findsOneWidget);
  });
}
