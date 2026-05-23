import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/session/app_session.dart';
import 'utils/router/app_router.dart';
import 'utils/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSession.load();
  runApp(const ProviderScope(child: ReClaimApp()));
}

class ReClaimApp extends StatelessWidget {
  const ReClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
