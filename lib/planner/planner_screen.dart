import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../Goal_Engine/goal_setup.dart';
import '../services/course_service.dart';
import 'planner_course_item.dart';
import 'planner_mode_switcher.dart';
import '../graph/visual_paths_screen.dart';
import '../utils/side_panel.dart';
import '../graph/dag_graph_screen.dart';
import 'add_course_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late String _activeMode;
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _activeMode = GoalSetupScreen.selectedGoal;
    if (_activeMode == 'Both — CGPA + Career') {
      _activeMode = 'Improve my CGPA';
    }
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await CourseService.getCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading courses: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E9),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlannerModeSwitcher(
                        activeMode: _activeMode,
                        onModeChanged: (mode) => setState(() => _activeMode = mode),
                      ),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('Manage Courses'),
                      SizedBox(height: 16.h),
                      if (_courses.isEmpty)
                        _buildEmptyState()
                      else
                        ..._courses.map((course) => PlannerCourseItem(
                          course: course,
                          activeMode: _activeMode,
                          onTap: () => _showCourseDetails(course),
                        )),
                      SizedBox(height: 24.h),
                      _buildActionButtons(),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: const Color(0xFFFFD93D).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.library_books_outlined, size: 48.sp, color: const Color(0xFFFF9A00).withValues(alpha: 0.5)),
          SizedBox(height: 16.h),
          Text(
            'No courses added yet',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: const Color(0xFF4F200D),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your current semester courses to start planning',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F1E9),
        border: Border(bottom: BorderSide(color: Color(0xFFFF9A00), width: 1)),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 48.h, 16.w, 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: const Color(0xFF4F200D), size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Academic Planner',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4F200D),
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: const Color(0xFF491706), size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F200D),
          ),
        ),
        IconButton(
          onPressed: () async {
            final result = await showSidePanel(
              context: context,
              screen: const AddCourseScreen(),
            );
            if (result == true) _loadCourses();
          },
          icon: Icon(Icons.add_circle_outline_rounded, color: const Color(0xFFFF9A00), size: 24.sp),
        ),
      ],
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6F1E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32.w))),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(32.w, 32.h, 32.w, MediaQuery.of(context).padding.bottom + 16.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course['name'], style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        Text(course['course_code'], style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handleDeleteCourse(course['id'].toString()),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildDetailRow(Icons.star_outline, 'Credits', '${course['credit_hours']}'),
              _buildDetailRow(Icons.calendar_today_outlined, 'Semester', course['semester']),
              if (course['teacher_name'] != null)
                _buildDetailRow(Icons.person_outline, 'Teacher', course['teacher_name']),
              SizedBox(height: 24.h),
              CustomButton(
                content: 'View Topic Graph',
                width: double.infinity,
                variant: 'outline',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DAGGraphScreen(
                        courseId: course['id'].toString(),
                        courseName: course['name'],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
              CustomButton(
                content: 'Close',
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: const Color(0xFFFF9A00)),
          SizedBox(width: 12.w),
          Text('$label: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Future<void> _handleDeleteCourse(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course?'),
        content: const Text('This will permanently remove this course.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await CourseService.deleteCourse(id);
      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      _loadCourses();
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            content: 'Visual Paths',
            size: 'small',
            iconPresent: true,
            icon: Icon(Icons.account_tree_rounded, color: const Color(0xFF4F200D), size: 16.sp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisualPathsScreen()),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: CustomButton(
            content: 'Study Plan',
            size: 'small',
            iconPresent: true,
            icon: Icon(Icons.auto_awesome_rounded, color: const Color(0xFF4F200D), size: 16.sp),
            onPressed: () {
              Navigator.pushNamed(context, '/smart_scheduler');
            },
          ),
        ),
      ],
    );
  }
}
