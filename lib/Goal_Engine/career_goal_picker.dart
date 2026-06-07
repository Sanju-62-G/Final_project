import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../Components/toolcard.dart';
import '../models/goal_setup_data.dart';
import '../services/goal_service.dart';
import '../services/course_service.dart';
import 'academic_setup.dart';

class CareerGoalPickerScreen extends StatefulWidget {
  final GoalSetupData? goalData;
  const CareerGoalPickerScreen({super.key, this.goalData});

  @override
  State<CareerGoalPickerScreen> createState() => _CareerGoalPickerScreenState();
}

class _CareerGoalPickerScreenState extends State<CareerGoalPickerScreen> {
  int _selectedRoleIndex = -1;
  late GoalSetupData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.goalData ?? GoalSetupData();
  }

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Flutter Developer',
      'key': 'flutter_developer',
      'icon': Icons.phone_android_outlined,
      'color': const Color(0xFF0284C7),
      'skills': ['Dart', 'Flutter', 'Firebase'],
    },
    {
      'title': 'Web Developer',
      'key': 'web_developer',
      'icon': Icons.language_outlined,
      'color': const Color(0xFF7C3AED),
      'skills': ['React', 'Next.js', 'Tailwind'],
    },
    {
      'title': 'Software Engineer',
      'key': 'software_engineer',
      'icon': Icons.code_outlined,
      'color': const Color(0xFF059669),
      'skills': ['Java', 'C++', 'Algorithms'],
    },
    {
      'title': 'Data Scientist',
      'key': 'data_scientist',
      'icon': Icons.bar_chart_outlined,
      'color': const Color(0xFFDC2626),
      'skills': ['Python', 'SQL', 'Statistics'],
    },
    {
      'title': 'AI/ML Engineer',
      'key': 'ai_ml_engineer',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFFEA580C),
      'skills': ['PyTorch', 'Linear Algebra'],
    },
    {
      'title': 'Backend Developer',
      'key': 'backend_developer',
      'icon': Icons.storage_outlined,
      'color': const Color(0xFF4F46E5),
      'skills': ['Node.js', 'Go', 'Docker'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF4F200D), size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: Center(
              child: Text(
                'Step 2 of 3',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4F200D).withAlpha(150),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What do you want to become?",
                  style: GoogleFonts.interTight(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F200D),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Pick the role that matches your future goal",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF4F200D).withAlpha(180),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Center(
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 16.h,
                  children: List.generate(
                    _roles.length,
                    (index) => _buildRoleCard(index),
                  ),
                ),
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildRoleCard(int index) {
    bool isSelected = _selectedRoleIndex == index;
    final role = _roles[index];

    return ToolCard(
      isSelected: isSelected,
      onTap: () => setState(() => _selectedRoleIndex = index),
      title: role['title'],
      bgTint: (role['color'] as Color).withAlpha(isSelected ? 60 : 25),
      icon: Icon(
        role['icon'],
        color: role['color'],
        size: 20.sp,
      ),
      subtitleWidget: Wrap(
        spacing: 4.w,
        runSpacing: 4.h,
        children: (role['skills'] as List<String>)
            .map((skill) => _buildSkillTag(skill))
            .toList(),
      ),
    );
  }

  Widget _buildSkillTag(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: const Color(0xFFFFD93D).withAlpha(100)),
      ),
      child: Text(
        skill,
        style: GoogleFonts.poppins(
          fontSize: 8.sp,
          color: const Color(0xFF4F200D),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E9),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            content: 'Continue',
            width: double.infinity,
            onPressed: _selectedRoleIndex != -1
                ? () async {
                    final selectedRoleKey = _roles[_selectedRoleIndex]['key'] as String;
                    _data.careerGoal = selectedRoleKey;

                    if (_data.selectedGoal == 'Build my career path') {
                      await _saveAndFinish();
                    } else {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicSetupScreen(goalData: _data),
                        ),
                      );
                    }
                  }
                : null,
            size: 'medium',
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndFinish() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF9A00),
        ),
      ),
    );

    try {
      await GoalService.saveGoal(
        selectedGoal: _data.selectedGoal ?? 'Build my career path',
        careerGoal: _data.careerGoal,
        semester: _data.semester ?? 'N/A',
      );

      // Career template load করো
      if (_data.careerGoal != null) {
        await CourseService.setupCareerPresets(_data.careerGoal!);
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goals: $e')),
      );
    }
  }
}
