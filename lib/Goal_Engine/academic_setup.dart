import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../models/goal_setup_data.dart';
import '../services/goal_service.dart';
import '../services/course_service.dart';

class AcademicSetupScreen extends StatefulWidget {
  final GoalSetupData? goalData;
  const AcademicSetupScreen({super.key, this.goalData});

  @override
  State<AcademicSetupScreen> createState() => _AcademicSetupScreenState();
}

class _AcademicSetupScreenState extends State<AcademicSetupScreen> {
  final TextEditingController _currentCgpaController = TextEditingController();
  final TextEditingController _targetCgpaController = TextEditingController();
  String _insightTitle = "Out of 4.0";
  String _insightMessage = "Enter your goals to see the path ahead";
  late GoalSetupData _data;

  @override
  void initState() {
    super.initState();
    _currentCgpaController.addListener(_updateHint);
    _targetCgpaController.addListener(_updateHint);
    _data = widget.goalData ?? GoalSetupData();
  }

  void _updateHint() {
    double current = double.tryParse(_currentCgpaController.text) ?? 0.0;
    double target = double.tryParse(_targetCgpaController.text) ?? 0.0;

    if (target > 0 && target <= 4.0) {
      if (target > current) {
        double diff = target - current;
        setState(() {
          _insightTitle = "+${diff.toStringAsFixed(2)} Increase Needed";
          _insightMessage = "You're aiming for a strong improvement! We'll help you plan your study hours.";
        });
      } else if (target < current && current > 0) {
        setState(() {
          _insightTitle = "Target below current";
          _insightMessage = "It's usually better to aim higher! Try setting a target above your current CGPA.";
        });
      } else if (target == current && current > 0) {
        setState(() {
          _insightTitle = "Steady Progress";
          _insightMessage = "Great! Consistency is key. Let's work on maintaining this performance.";
        });
      } else {
        setState(() {
          _insightTitle = "Target Set: ${target.toStringAsFixed(2)}";
          _insightMessage = "A solid goal. Let's break it down into manageable semester targets.";
        });
      }
    } else {
      setState(() {
        _insightTitle = "Out of 4.0";
        _insightMessage = "Enter your goals to see the path ahead";
      });
    }
  }

  @override
  void dispose() {
    _currentCgpaController.dispose();
    _targetCgpaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final bool isFirstSemester = _data.semester == 'Semester 1';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              SizedBox(height: 32.h),
              _buildTitleSection(),
              SizedBox(height: 32.h),
              _buildInsightCard(),
              SizedBox(height: 32.h),
              if (!isFirstSemester) ...[
                _buildInputLabel("Current CGPA"),
                SizedBox(height: 12.h),
                _buildTextField('Enter your current CGPA', controller: _currentCgpaController),
                SizedBox(height: 24.h),
              ],
              _buildInputLabel("Targeted CGPA"),
              SizedBox(height: 12.h),
              _buildTextField('Enter your targeted CGPA', controller: _targetCgpaController),
              SizedBox(height: 16.h),
              _buildQuickSelection(),
              SizedBox(height: 48.h),
              CustomButton(
                content: "Let's Go!",
                width: double.infinity,
                onPressed: () async {
                  _data.currentCgpa = double.tryParse(_currentCgpaController.text);
                  _data.targetCgpa = double.tryParse(_targetCgpaController.text);
                  
                  if (_data.selectedGoal == 'Both — CGPA + Career') {
                    _data.cgpaPriorityRatio = 0.5;
                  }

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
                      selectedGoal: _data.selectedGoal ?? 'Improve my CGPA',
                      careerGoal: _data.careerGoal,
                      currentCgpa: _data.currentCgpa,
                      targetCgpa: _data.targetCgpa,
                      cgpaPriorityRatio: _data.cgpaPriorityRatio,
                      semester: _data.semester ?? 'N/A',
                    );

                    // Career goal থাকলে template load করো
                    if (_data.careerGoal != null && _data.careerGoal!.isNotEmpty) {
                      debugPrint('=== LOADING TEMPLATE: ${_data.careerGoal} ===');
                      
                      // CourseService.setupCareerPresets use করো
                      await CourseService.setupCareerPresets(_data.careerGoal!);
                      
                      debugPrint('=== TEMPLATE LOADED ===');
                    }
                    
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
                  } catch (e) {
                    debugPrint('Error: $e');
                    if (!context.mounted) return;
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                size: 'medium',
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: const Color(0xFF4F200D), size: 18.sp),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(12.w),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Text(
            'Step 3 of 3',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4F200D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic\nBaseline',
          style: GoogleFonts.poppins(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF491706),
            height: 1.1,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9A00),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9846E5),
            Color(0xFFEAB712),
          ],
          stops: [0, 1],
          begin: AlignmentDirectional(0, -1),
          end: AlignmentDirectional(0, 1),
        ),
        borderRadius: BorderRadius.circular(24.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9846E5).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _insightTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _insightMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4F200D).withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildQuickSelection() {
    final targets = ['3.50', '3.80', '4.00'];
    return Wrap(
      spacing: 12.w,
      children: targets.map((val) {
        return ActionChip(
          label: Text(val),
          onPressed: () => _targetCgpaController.text = val,
          backgroundColor: Colors.white,
          labelStyle: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4F200D),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
            side: const BorderSide(color: Color(0xFFFFD93D)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: const Color(0xFF4F200D),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFF94A3B8),
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
