import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/claims/Riverpod/claims_provider.dart';
import 'package:frontend/features/claims/presentation/screens/claim_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('shows the app bar and a loading spinner', (tester) async {
    await tester.pumpWidget(wrapApp(
      const ClaimsScreen(),
      overrides: [
        claimsListProvider.overrideWith(
          (ref) => Completer<List<dynamic>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.text('My Claims'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders the empty claims state', (tester) async {
    await tester.pumpWidget(wrapApp(
      const ClaimsScreen(),
      overrides: [
        claimsListProvider.overrideWith((ref) async => <dynamic>[]),
      ],
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ClaimsScreen), findsOneWidget);
  });
}
