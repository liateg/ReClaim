// UI-driven item creation flow (on emulator).
//
// Drives: login -> open the "Post an Item" screen -> fill the form -> submit ->
// verify the success snackbar. This DOES create a real item on your backend.
//
// Prerequisites: backend running + booted emulator + valid credentials.
//
// Run with:
//   flutter test integration_test/item_creation_flow_test.dart -d emulator-5554
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/core/session/app_session.dart';

import 'flow_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('item creation flow: login -> post an item -> submit',
      (tester) async {
    await AppSession.signOut();

    await tester.pumpWidget(const ProviderScope(child: ReClaimApp()));
    await logStep(tester, 'App launched — splash screen visible');

    final loggedIn = await loginViaUi(tester);
    expect(loggedIn, isTrue,
        reason: 'Login must succeed before posting an item.');
    debugPrint('UI STEP -> Logged in');

    // Open the create-item screen (nav-agnostic).
    await goTo(tester, '/post');
    debugPrint('UI STEP -> Opened the "Post an Item" screen');
    expect(find.text('Post an Item'), findsWidgets);

    // Fill the five fields: title, location, description, question, answer.
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(5));
    final tag = DateTime.now().millisecondsSinceEpoch;

    await tester.enterText(fields.at(0), 'Test Item $tag');
    await logStep(tester, 'Entered item title');
    await tester.enterText(fields.at(1), 'Central Library, 2nd Floor');
    await logStep(tester, 'Entered location');
    await tester.enterText(fields.at(2), 'A test item created by the UI flow.');
    await logStep(tester, 'Entered description');
    await tester.enterText(fields.at(3), 'What sticker is on it?');
    await logStep(tester, 'Entered verification question');
    await tester.enterText(fields.at(4), 'Blue star');
    await logStep(tester, 'Entered verification answer');

    // Submit the form.
    final postButton = find.text('Post Item →');
    await tester.ensureVisible(postButton);
    await tester.pumpAndSettle();
    debugPrint('UI STEP -> Tapping "Post Item" to submit');
    await tester.tap(postButton);

    final posted = await waitFor(tester, find.text('Item posted successfully.'));
    debugPrint('UI RESULT -> itemPosted=$posted');
    expect(
      posted,
      isTrue,
      reason: 'Expected the "Item posted successfully." snackbar. If this '
          'fails, check the backend accepted the new item.',
    );
    debugPrint('ITEM CREATION FLOW COMPLETED SUCCESSFULLY');
  });
}
