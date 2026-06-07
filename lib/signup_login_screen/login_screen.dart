import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Components/custom_button.dart';
import '../Components/custom_text_field.dart';
import '../Components/social_button.dart';
import '../Components/app_logo.dart';
import '../utils/responsive.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      String errorMessage = e.message;
      if (errorMessage == 'Invalid login credentials') {
        errorMessage = 'Wrong password. Enter correct password';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(),
                  SizedBox(height: 32.h),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.poppins(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF491706),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Log in to continue your academic progress.',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomTextField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Enter your email' : null,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                  ),
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9A00),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    content: 'Login',
                    width: double.infinity,
                    loading: _isLoading,
                    onPressed: _handleLogin,
                    size: 'large',
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'OR',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SocialButton(
                    label: 'Continue with Google',
                    icon: Image.network(
                      'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                      height: 20.h,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.g_mobiledata, color: const Color(0xFF4285F4), size: 24.sp),
                    ),
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final response = await AuthService.instance.signInWithGoogle();
                        if (response != null && response.user != null) {
                          if (!mounted) return;
                          
                          // Check if it's a new user by checking profile
                          final profile = await AuthService.instance.getUserProfile();
                          if (!context.mounted) return;

                          if (profile == null || profile['selected_goal'] == null) {
                            Navigator.pushNamedAndRemoveUntil(context, '/goal_setup', (route) => false);
                          } else {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          }
                        }
                      } catch (e) {
                        debugPrint('Google Sign In Error: $e');
                        _showError('Google Sign In failed. Please try again.');
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),
                  SizedBox(height: 12.h),
                  SocialButton(
                    label: 'Continue with Apple',
                    icon: Icon(Icons.apple, color: Colors.black, size: 22.sp),
                    onPressed: () {},
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF64748B),
                          fontSize: 14.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF9A00),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
