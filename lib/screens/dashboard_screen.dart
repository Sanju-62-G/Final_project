import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Components/custom_button.dart';
import '../Components/deadline_item.dart';
import '../Components/toolcard.dart';
import '../utils/responsive.dart';
import '../utils/side_panel.dart';
import '../services/auth_service.dart';
import '../services/deadline_service.dart';
import '../services/goal_service.dart';
import '../services/course_service.dart';
import '../services/topic_service.dart';
import '../Goal_Engine/goal_setup.dart';
import 'add_deadline_screen.dart';
import 'edit_deadline_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static String routeName = 'MainDashboard';
  static String routePath = '/mainDashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _deadlines = [];
  String _userName = 'Sami';
  String _currentGoal = 'Improve my CGPA';
  double _currentCgpa = 3.82;
  double _targetCgpa = 4.0;
  String _semester = 'N/A';
  bool _isLoading = true;

  // Stats
  int _topicsDoneCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadUserData(),
      _loadStats(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadStats() async {
    try {
      final courses = await CourseService.getCourses();
      int completedTopics = 0;

      for (var course in courses) {
        final topics = await TopicService.getTopics(course['id'].toString());
        for (var topic in topics) {
          if (topic['is_completed'] == true) {
            completedTopics++;
          }
        }
      }

      setState(() {
        _topicsDoneCount = completedTopics;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  double _calculateOverallProgress() {
    if (_currentGoal == 'Improve my CGPA') {
      return (_currentCgpa / _targetCgpa).clamp(0.0, 1.0);
    } else if (_currentGoal == 'Build my career path') {
      // Assuming 50 topics is 100% readiness for simplicity, or we can use a fixed scale
      return (_topicsDoneCount / 50).clamp(0.0, 1.0);
    } else {
      // Both: 50/50 split
      double cgpaProgress = (_currentCgpa / _targetCgpa).clamp(0.0, 1.0);
      double careerProgress = (_topicsDoneCount / 50).clamp(0.0, 1.0);
      return (cgpaProgress + careerProgress) / 2;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (profile != null) {
        setState(() {
          _userName = profile['full_name']?.split(' ')[0] ?? 'User';
        });
      }

      final goalData = await GoalService.getUserGoal();
      if (goalData != null) {
        setState(() {
          _currentGoal = goalData['selected_goal'] ?? 'Improve my CGPA';
          _currentCgpa = (goalData['current_cgpa'] ?? 0.0).toDouble();
          _targetCgpa = (goalData['target_cgpa'] ?? 4.0).toDouble();
          _semester = goalData['semester'] ?? 'N/A';
          
          // Update static for compatibility with other parts of the app
          GoalSetupScreen.selectedGoal = _currentGoal;
        });
      }

      final deadlines = await DeadlineService.getDeadlines();
      setState(() {
        _deadlines = deadlines;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  String _formatDeadlineTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    String dateStr;
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      dateStr = 'Today';
    } else if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
      dateStr = 'Tomorrow';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateStr = '${months[dateTime.month - 1]} ${dateTime.day}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$dateStr, $hour:$minute $amPm';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF6F1E9),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A00)))
          : SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24.w, 24.h, 24.w, 16.h),
                    child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning, $_userName',
                          style: GoogleFonts.interTight(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4F200D),
                          ),
                        ),
                        Text(
                          _semester == 'N/A' ? 'Current Semester' : _semester,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF4F200D),
                            height: 1.4,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4.h),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9A00).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.w),
                            border: Border.all(color: const Color(0xFFFF9A00).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _currentGoal,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF9A00),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 4.h)),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        debugPrint('IconButton pressed ...');
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        fixedSize: Size(36.w, 36.w),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.w, 0, 24.w, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9846E5),
                        Color(0xFFEAB712),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24.w),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15.w,
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: Offset(0, 8.h),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentGoal == 'Build my career path'
                                ? 'Career Readiness'
                                : _currentGoal == 'Both — CGPA + Career'
                                  ? 'Overall Progress'
                                  : 'Current CGPA',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _currentGoal == 'Build my career path' 
                                    ? '${(_calculateOverallProgress() * 100).toInt()}%'
                                    : _currentGoal == 'Both — CGPA + Career'
                                      ? '$_currentCgpa / ${(_calculateOverallProgress() * 100).toInt()}%'
                                      : '$_currentCgpa',
                                  style: GoogleFonts.inter(
                                    fontSize: _currentGoal == 'Both — CGPA + Career' ? 20.sp : 28.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_currentGoal == 'Improve my CGPA')
                                  Text(
                                    '/ $_targetCgpa',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                              ].divide(SizedBox(width: 4.w)),
                            ),
                          ].divide(SizedBox(height: 4.h)),
                        ),
                        SizedBox(
                          width: 56.w,
                          height: 56.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 56.w,
                                height: 56.w,
                                child: CircularProgressIndicator(
                                  value: _calculateOverallProgress(),
                                  strokeWidth: 4.w,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              Text(
                                '${(_calculateOverallProgress() * 100).toInt()}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Tools',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4F200D),
                        height: 1.4,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ToolCard(
                                bgTint: const Color(0xFFE0E7FF),
                                icon: Icon(
                                  Icons.auto_stories_rounded,
                                  color: const Color(0xFF4F46E5),
                                  size: 20.sp,
                                ),
                                subtitle: 'Manage Courses',
                                onTap: () => Navigator.pushNamed(context, '/planner'),
                                title: 'Planner',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ToolCard(
                                bgTint: const Color(0xFFDCFCE7),
                                icon: Icon(
                                  Icons.account_tree_rounded,
                                  color: const Color(0xFF22C55E),
                                  size: 20.sp,
                                ),
                                subtitle: 'Visual Paths',
                                onTap: () => Navigator.pushNamed(context, '/graph'),
                                title: 'DAG Graph',
                              ),
                            ),
                          ].divide(SizedBox(width: 16.w)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ToolCard(
                                bgTint: const Color(0xFFFEF3C7),
                                icon: Icon(
                                  Icons.functions_rounded,
                                  color: const Color(0xFFD97706),
                                  size: 20.sp,
                                ),
                                subtitle: _currentGoal == 'Build my career path' 
                                  ? 'Career Simulation' 
                                  : _currentGoal == 'Both — CGPA + Career'
                                    ? 'CGPA + Career'
                                    : 'Predict GPA',
                                onTap: () => Navigator.pushNamed(
                                  context, 
                                  '/gpa',
                                  arguments: _currentGoal,
                                ),
                                title: 'Simulator',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ToolCard(
                                bgTint: const Color(0xFFFDE68A).withValues(alpha: 0.1),
                                icon: Icon(
                                  Icons.map_rounded,
                                  color: const Color(0xFFF59E0B),
                                  size: 20.sp,
                                ),
                                subtitle: 'Future Skills',
                                onTap: () => Navigator.pushNamed(context, '/roadmap'),
                                title: 'Roadmap',
                              ),
                            ),
                          ].divide(SizedBox(width: 16.w)),
                        ),
                      ].divide(SizedBox(height: 16.h)),
                    ),
                  ].divide(SizedBox(height: 16.h)),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.w, 0, 24.w, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F2),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.w,
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: Offset(0, 4.h),
                      )
                    ],
                    borderRadius: BorderRadius.circular(24.w),
                    border: Border.all(
                      color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Study Activity',
                              style: GoogleFonts.interTight(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4F200D),
                              ),
                            ),
                            Text(
                              'This Week',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFF9A00),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 100.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [0.4, 0.6, 0.3, 0.8, 0.5, 0.2, 0.7].map((val) => Container(
                              width: 18.w,
                              height: (val * 80).h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD93D),
                                borderRadius: BorderRadius.circular(6.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF9A00).withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                            )).toList(),
                          ),
                        ),
                      ].divide(SizedBox(height: 20.h)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Upcoming Deadlines',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4F200D),
                            height: 1.4,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await showSidePanel(
                                  context: context,
                                  screen: const AddDeadlineScreen(),
                                );
                                _loadUserData();
                              },
                              icon: Icon(Icons.add_circle_outline_rounded, color: const Color(0xFFFF9A00), size: 22.sp),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(width: 8.w),
                            CustomButton(
                              content: 'View All',
                              variant: 'ghost',
                              size: 'small',
                              onPressed: () async {
                                await Navigator.pushNamed(context, '/all_deadlines');
                                _loadUserData();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _deadlines.isEmpty 
                        ? [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Text(
                                'No upcoming deadlines',
                                style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
                              ),
                            )
                          ]
                        : _deadlines.take(3).map((deadline) {
                            // Assign colors based on urgency
                            final deadlineTime = DateTime.parse(deadline['deadline_at']);
                            final diff = deadlineTime.difference(DateTime.now()).inDays;
                            Color accentColor = const Color(0xFF22C55E); // Green (More than 3 days)
                            if (diff <= 1) {
                              accentColor = const Color(0xFFEF4444); // Red (Today or Tomorrow)
                            } else if (diff <= 3) {
                              accentColor = const Color(0xFFF59E0B); // Amber (Within 3 days)
                            }

                            return DeadlineItem(
                              accentColor: accentColor,
                              course: deadline['course_code'] ?? 'N/A',
                              time: _formatDeadlineTime(deadline['deadline_at']),
                              title: deadline['title'] ?? 'Untitled',
                              onEdit: () async {
                                final result = await showSidePanel(
                                  context: context,
                                  screen: EditDeadlineScreen(deadline: deadline),
                                );
                                if (result == true) {
                                  _loadUserData();
                                }
                              },
                              onDelete: () async {
                                final bool confirm = await _showDeleteDialog(deadline['title']);
                                if (confirm) {
                                  await DeadlineService.deleteDeadline(deadline['id']);
                                  _loadUserData();
                                }
                              },
                            );
                          }).toList().divide(SizedBox(height: 8.h)),
                    ),
                  ].divide(SizedBox(height: 16.h)),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(String? title) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6F1E9),
        title: Text('Remove Deadline', style: GoogleFonts.interTight(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }
}

extension ListDivide on List<Widget> {
  List<Widget> divide(Widget separator) {
    if (isEmpty) return this;
    return [
      for (var i = 0; i < length; i++) ...[
        if (i > 0) separator,
        this[i],
      ],
    ];
  }
}
