import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Components/custom_button.dart';
import '../Components/social_button.dart';
import '../Components/custom_text_field.dart';
import '../Components/custom_dropdown_field.dart';
import '../Components/app_logo.dart';
import '../utils/responsive.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedSemester;
  bool _isLoading = false;

  final List<String> _departments = ['CSE', 'EEE', 'BBA', 'English', 'Law'];
  final List<String> _semesters = List.generate(12, (index) => 'Semester ${index + 1}');

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDepartment == null) {
      _showError('Please select your department');
      return;
    }
    if (_selectedSemester == null) {
      _showError('Please select your current semester');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        studentId: _idController.text.trim(),
        department: _selectedDepartment!,
        semester: _selectedSemester!,
      );

      if (response.user != null) {
        if (!mounted) return;

        if (response.session != null) {
          // User is logged in automatically
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Let\'s set your goals.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/goal_setup',
            (route) => false,
            arguments: _selectedSemester,
          );
        } else {
          // Email confirmation might be required
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Please check your email to confirm your account, then login.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      // বিস্তারিত এরর দেখাবে যাতে আমরা সমস্যা বুঝতে পারি
      _showError(e.toString());
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(),
                SizedBox(height: 24.h),
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF491706),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Start your organized academic journey with TopoTrack.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 32.h),
                CustomTextField(
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                  validator: (v) => v!.isEmpty ? 'Enter your full name' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Student ID',
                  icon: Icons.badge_outlined,
                  controller: _idController,
                  validator: (v) => v!.isEmpty ? 'Enter your student ID' : null,
                ),
                SizedBox(height: 16.h),
                CustomDropdownField(
                  label: 'Department',
                  icon: Icons.school_outlined,
                  value: _selectedDepartment,
                  items: _departments,
                  onChanged: (v) => setState(() => _selectedDepartment = v),
                ),
                SizedBox(height: 16.h),
                CustomDropdownField(
                  label: 'Semester',
                  icon: Icons.calendar_month_outlined,
                  value: _selectedSemester,
                  items: _semesters,
                  onChanged: (v) => setState(() => _selectedSemester = v),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Email',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  label: 'Confirm Password',
                  icon: Icons.lock_reset_rounded,
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  content: 'Create Account',
                  width: double.infinity,
                  loading: _isLoading,
                  onPressed: _handleSignup,
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

                        // If no profile or no goal set, go to goal setup
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
                      "Already have an account? ",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 14.sp,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9A00),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
