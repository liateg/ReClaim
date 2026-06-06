import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/admin_dashboard.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the command center dashboard', (tester) async {
    await tester.pumpWidget(wrapApp(const AdminDashboard()));
    await tester.pump();

    expect(find.text('Command Center'), findsOneWidget);
    expect(find.text('Management Modules'), findsOneWidget);
    expect(find.text('All Posted Items'), findsOneWidget);
  });
}
