import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'signup_login_screen/login_screen.dart';
import 'signup_login_screen/signup_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'screens/main_container.dart';
import 'screens/scheduler_screen.dart';
import 'simulator_parts/career_simulator_screen.dart';
import 'simulator_parts/hybrid_simulator_screen.dart';
import 'simulator_parts/simulator_router.dart';
import 'roadmap/roadmap_screen.dart';
import 'planner/planner_screen.dart';
import 'graph/visual_paths_screen.dart';
import 'screens/profile_screen.dart';
import 'settings/personal_info_page.dart';
import 'settings/goal_mood_page.dart';
import 'settings/security_privacy_page.dart';
import 'settings/change_password_page.dart';
import 'screens/add_task_screen.dart';
import 'screens/add_deadline_screen.dart';
import 'screens/all_deadlines_screen.dart';
import 'signup_login_screen/forgot_pass.dart';
import 'Goal_Engine/goal_setup.dart';
import 'Goal_Engine/career_goal_picker.dart';
import 'Goal_Engine/academic_setup.dart';
import 'screens/smart_scheduler_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

const String webClientId = '58701316295-8urur3knf2soebbhurg3klp6b23foeba.apps.googleusercontent.com';
const String iosClientId = '58701316295-377olqq43s5hqnh9bds6m9h487gc8506.apps.googleusercontent.com';
const String androidClientId = '58701316295-ovr6cfqh5p5odnvj3f551o3h57d466g6.apps.googleusercontent.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  await Supabase.initialize(
      url: "https://ysgspvfhpicigyrdzkuv.supabase.co",
      // IMPORTANT: The key below looks like a Stripe key. 
      // Please replace it with your Supabase 'anon public' key from Settings -> API.
      anonKey: "sb_publishable_3kY2RKRINOq3J5R3EWtdxA_Ptv7MtRI"
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TopoTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF06B6D4),
          surface: const Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: AuthService.isLoggedIn()
          ? const MainContainer()
          : const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const MainContainer(),
        '/scheduler': (context) => const SchedulerScreen(),
        '/gpa': (context) => const SimulatorRouter(),
        '/career_simulator': (context) => const CareerSimulatorScreen(),
        '/hybrid_simulator': (context) => const HybridSimulatorScreen(),
        '/roadmap': (context) => const RoadmapScreen(),
        '/planner': (context) => const PlannerScreen(),
        '/graph': (context) => const VisualPathsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/personal_info': (context) => const PersonalInfoPage(),
        '/goal_mood': (context) => const GoalMoodPage(),
        '/security_privacy': (context) => const SecurityPrivacyPage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/add_task': (context) => const AddTaskScreen(),
        '/add_deadline': (context) => const AddDeadlineScreen(),
        '/all_deadlines': (context) => const AllDeadlinesScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/goal_setup': (context) => const GoalSetupScreen(),
        '/career_picker': (context) => const CareerGoalPickerScreen(),
        '/academic_setup': (context) => const AcademicSetupScreen(),
        '/smart_scheduler': (context) => const SmartScheduler(),
      },
    );
  }
}
