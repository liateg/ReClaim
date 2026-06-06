import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/admin/admin_claims_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await initInMemoryCache();
  });

  setUp(() {
    mockSecureStorage({'token': 'token123'});
  });

  tearDown(clearSecureStorageMock);

  testWidgets('renders the claimed-items header', (tester) async {
    // The screen's repository touches sqflite (isolate-backed) and Dio, which
    // both need the real event loop. Driving the pump inside runAsync lets the
    // offline-stubbed request resolve with real timers instead of fake ones.
    await tester.runAsync(() async {
      await tester.pumpWidget(wrapApp(const AdminClaimsScreen()));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();

    expect(find.byType(AdminClaimsScreen), findsOneWidget);
    expect(find.text('Claimed Items'), findsOneWidget);
  });
}
