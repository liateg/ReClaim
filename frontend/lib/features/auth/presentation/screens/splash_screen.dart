import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../utils/router/route_paths.dart';
import '../../Riverpod/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Small delay for branding
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final isLoggedIn = await ref.read(authProvider.future);
    if (isLoggedIn) {
      final isAdmin = ref.read(isAdminProvider);
      if (isAdmin) {
        context.go(RoutePaths.adminDashboard);
      } else {
        context.go(RoutePaths.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                    angle: -0.04,
                    child: Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.transparent, width: 1),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/images/img_1.png',
                            width: 300,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ))),
                Positioned(
                    bottom: -35,
                    right: -3,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/img.png',
                              width: 120,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          )),
                    ))
              ],
            ),
            const Spacer(),
            const AppLogo(showTagline: true),
            const Spacer(),
            CustomButton(
              text: 'Get Started -> ',
              onPressed: () {
                context.push('/register');
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C3E1B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      )),
    );
  }
}
