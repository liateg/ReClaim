import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/reports/data/models/report_model.dart';
import 'package:frontend/features/reports/presentation/screens/adminPages/admin_report_details.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the details for a given report', (tester) async {
    final report = Report(
      id: 12,
      reporterId: 3,
      itemId: 5,
      reason: ReportReason.spam,
      status: ReportStatus.pending,
      description: 'Suspicious listing',
    );

    await tester.pumpWidget(wrapApp(
      AdminReportsDetailScreen(report: report),
    ));
    await tester.pump();

    expect(find.byType(AdminReportsDetailScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
