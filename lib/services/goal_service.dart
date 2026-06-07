import 'supabase_client.dart';
import 'career_template_service.dart';

class GoalService {
  // Goal save করো
  static Future<void> saveGoal({
    required String selectedGoal,
    String? careerGoal,
    double? currentCgpa,
    double? targetCgpa,
    double? cgpaPriorityRatio,
    required String semester,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await SupabaseClientService.from('users').update({
      'selected_goal': selectedGoal,
      'career_goal': careerGoal,
      'current_cgpa': currentCgpa,
      'target_cgpa': targetCgpa,
      'cgpa_priority_ratio': cgpaPriorityRatio ?? 0.5,
      'semester': semester,
    }).eq('id', userId);
  }

  // Goal save and Load Career Template
  static Future<void> saveGoalWithTemplate({
    required String selectedGoal,
    String? careerGoal,
    double? currentCgpa,
    double? targetCgpa,
    double? cgpaPriorityRatio,
    required String semester,
  }) async {
    // 1. First, save the goal to user profile
    await saveGoal(
      selectedGoal: selectedGoal,
      careerGoal: careerGoal,
      currentCgpa: currentCgpa,
      targetCgpa: targetCgpa,
      cgpaPriorityRatio: cgpaPriorityRatio,
      semester: semester,
    );

    // 2. If a career goal is selected, load the corresponding academic template
    if (careerGoal != null && careerGoal.isNotEmpty) {
      await CareerTemplateService.loadCareerTemplate(careerGoal);
    }
  }

  // User goal data fetch করো
  static Future<Map<String, dynamic>?> getUserGoal() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return null;

    final data = await SupabaseClientService.from('users')
        .select('''
          selected_goal,
          career_goal,
          current_cgpa,
          target_cgpa,
          cgpa_priority_ratio,
          semester
        ''')
        .eq('id', userId)
        .maybeSingle();

    return data;
  }

  // Goal update করো (Settings থেকে)
  static Future<void> updateGoal({
    required String selectedGoal,
    String? careerGoal,
    double? targetCgpa,
    double? cgpaPriorityRatio,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await SupabaseClientService.from('users').update({
      'selected_goal': selectedGoal,
      'career_goal': careerGoal,
      'target_cgpa': targetCgpa,
      'cgpa_priority_ratio': cgpaPriorityRatio ?? 0.5,
    }).eq('id', userId);
  }
}
