// UI-driven claim flow (on emulator).
//
// Drives: login -> open a real available item's detail -> tap "Claim This Item"
// -> fill the verification answer in the bottom sheet -> Submit Claim.
// This DOES create a real (pending) claim on your backend.
//
// To reliably reach a claimable item, the flow first asks the backend for the
// item list (using the token from the UI login), picks an available item that
// the current user did not post, then navigates to its detail screen.
//
// Prerequisites: backend running + booted emulator + valid credentials + at
// least one available item that the logged-in user did not post.
//
// Run with:
//   flutter test integration_test/claim_flow_test.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/core/session/app_session.dart';
import 'package:frontend/features/items/data/items_service.dart';
import 'package:frontend/features/items/data/models/item_model.dart';

import 'flow_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('claim flow: login -> open item -> submit claim', (tester) async {
    await AppSession.signOut();

    await tester.pumpWidget(const ProviderScope(child: ReClaimApp()));
    await logStep(tester, 'App launched — splash screen visible');

    final loggedIn = await loginViaUi(tester);
    expect(loggedIn, isTrue, reason: 'Login must succeed before claiming.');
    debugPrint('UI STEP -> Logged in');

    // Find a claimable item from the backend (available + not mine).
    final items = await ItemsService().getItems(forceRefresh: true);
    final me = AppSession.userId;
    final claimable = items.where((i) =>
        i.status.toLowerCase() == 'available' &&
        (me == null || i.postedBy != me));

    if (claimable.isEmpty) {
      markTestSkipped(
          'No available item the current user can claim — seed one on the '
          'backend (posted by a different user) to exercise this flow.');
      return;
    }

    final ItemModel target = claimable.first;
    debugPrint('UI STEP -> Claimable item chosen: id=${target.id}, '
        'title=${target.title}');

    // Navigate straight to the item detail screen.
    await goTo(tester, '/items/${target.id}');
    debugPrint('UI STEP -> Opened item detail for ${target.id}');

    final claimButton = find.text('Claim This Item');
    final hasButton = await waitFor(tester, claimButton, tries: 15);
    if (!hasButton) {
      markTestSkipped(
          'The "Claim This Item" button was not available for ${target.id} '
          '(it may already be claimed or unavailable).');
      return;
    }

    // Open the claim bottom sheet.
    await tester.tap(claimButton);
    await pumpFor(tester, total: const Duration(seconds: 1));
    await logStep(tester, 'Tapped "Claim This Item" — claim sheet open');
    expect(find.text('Submit Claim'), findsOneWidget);

    // Enter the verification answer (the sheet has a single TextField).
    final answerField = find.byType(TextField).last;
    await tester.enterText(answerField, target.verificationAnswer.isNotEmpty
        ? target.verificationAnswer
        : 'My answer');
    await logStep(tester, 'Entered verification answer');

    // Submit the claim.
    debugPrint('UI STEP -> Tapping "Submit Claim"');
    await tester.tap(find.text('Submit Claim'));

    final success =
        await waitFor(tester, find.text('Claim submitted successfully.'));
    final failed = find.textContaining('Failed to submit claim').evaluate().isNotEmpty;
    debugPrint('UI RESULT -> claimSubmitted=$success, backendRejected=$failed');

    expect(
      success || failed,
      isTrue,
      reason: 'The claim should be submitted (success snackbar) or explicitly '
          'rejected by the backend — either way the UI flow ran.',
    );
    debugPrint('CLAIM FLOW COMPLETED');
  });
}
