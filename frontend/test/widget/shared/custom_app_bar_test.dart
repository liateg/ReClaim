import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/appbar.dart';

void main() {
  Widget host(Widget appBar) => MaterialApp(
        home: Scaffold(appBar: appBar as PreferredSizeWidget),
      );

  testWidgets('shows the title', (tester) async {
    await tester.pumpWidget(host(const CustomAppBar(title: 'My Reports')));
    expect(find.text('My Reports'), findsOneWidget);
  });

  testWidgets('shows the profile action by default', (tester) async {
    await tester.pumpWidget(host(const CustomAppBar(title: 'Home')));
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('hides the profile action when disabled', (tester) async {
    await tester.pumpWidget(
      host(const CustomAppBar(title: 'Home', showProfileAction: false)),
    );
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('renders a custom leading widget', (tester) async {
    await tester.pumpWidget(host(const CustomAppBar(
      title: 'Profile',
      leading: BackButton(),
    )));
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('exposes the standard toolbar height', (tester) async {
    const bar = CustomAppBar(title: 'X');
    expect(bar.preferredSize.height, kToolbarHeight);
  });
}
