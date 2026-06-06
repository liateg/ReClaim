import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('app builds', (WidgetTester tester) async {
    // The initial route (SplashScreen) lays out a tall Column, so give the
    // test a phone-sized surface to avoid a spurious RenderFlex overflow.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ReClaimApp());
    await tester.pump();
    expect(find.byType(ReClaimApp), findsOneWidget);
  });
}
