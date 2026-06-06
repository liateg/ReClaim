import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/claims/Riverpod/claims_provider.dart';
import 'package:frontend/features/claims/presentation/screens/claim_detail_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('shows the app bar and a loading spinner', (tester) async {
    await tester.pumpWidget(wrapApp(
      const ClaimDetailScreen(claimId: '1'),
      overrides: [
        claimProvider.overrideWith(
          (ref, id) => Completer<Map<String, dynamic>>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.text('Claim Details'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
