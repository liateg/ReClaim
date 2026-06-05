import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/Riverpod/auth_provider.dart';
import 'package:frontend/features/profile/Riverpod/profile_provider.dart';
import 'package:frontend/features/profile/profile_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUp(() {
    mockSecureStorage();
    resetAppSession();
  });

  tearDown(clearSecureStorageMock);

  testWidgets('shows the app bar and a loading spinner', (tester) async {
    await tester.pumpWidget(wrapApp(
      const ProfileScreen(),
      overrides: [
        authProvider.overrideWith((ref) => false),
        profileOverviewProvider.overrideWith(
          (ref) => Completer<ProfileOverview>().future,
        ),
      ],
    ));
    await tester.pump();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
