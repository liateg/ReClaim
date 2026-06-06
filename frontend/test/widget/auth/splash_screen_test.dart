import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/presentation/screens/splash_screen.dart';
import 'package:frontend/shared/widgets/app_logo.dart';
import 'package:frontend/shared/widgets/custom_button.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('renders the brand logo and a get-started button',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrapApp(const SplashScreen()));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('ReClaim'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
