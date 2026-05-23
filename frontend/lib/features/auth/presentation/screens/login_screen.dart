import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import '../../../../utils/router/route_paths.dart';
import '../../../../utils/theme/app_theme.dart';
import '../../riverpod/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isSubmitting = false;

  void _handleSignIn() async {
    setState(() {
      _generalError = null;
      _emailError = null;
      _passwordError = null;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        if (_emailController.text.isEmpty) {
          _emailError = 'Email is required';
        }
        if (_passwordController.text.isEmpty) {
          _passwordError = 'Password is required';
        }
        _generalError = 'Please fill in all fields';
      });
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Enter a valid email address';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final params = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };
      ref.invalidate(loginProvider(params));
      await ref.read(loginProvider(params).future);

      if (!mounted) return;

      invalidateAuthState(ref);
      final isLoggedIn = await ref.read(authProvider.future);
      final isAdmin = ref.read(isAdminProvider);

      if (!isLoggedIn) {
        setState(() {
          _generalError =
              'Sign-in completed but session was not saved. Please try again.';
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Welcome back, ${_emailController.text.split('@')[0]}!'),
          backgroundColor: AppTheme.primaryGreenLight,
        ),
      );

      if (isAdmin) {
        context.go(RoutePaths.adminDashboard);
      } else {
        context.go(RoutePaths.home);
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _generalError = message;
        if (message.toLowerCase().contains('password') ||
            message.toLowerCase().contains('invalid email')) {
          _passwordError = message;
        }
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              const Text(
                'Access your secure vault and track your items.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 32),
              if (_generalError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.accentRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _generalError!,
                          style: const TextStyle(
                              color: AppTheme.accentRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              CustomTextField(
                controller: _emailController,
                label: 'EMAIL ADDRESS',
                hint: 'abebe@aau.edu.et',
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'PASSWORD',
                hint: '·············',
                obscureText: true,
                errorText: _passwordError,
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Sign in',
                      onPressed: _handleSignIn,
                      isLoading: false,
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to Reclaim?',
                    style: TextStyle(fontSize: 14, color: AppTheme.grayText),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
