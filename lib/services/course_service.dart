import 'supabase_client.dart';

class CourseService {
  // Course add করো
  static Future<void> addCourse({
    required String name,
    required String courseCode,
    required double creditHours,
    required String semester,
    String? teacherName,
  }) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await SupabaseClientService.from('courses').insert({
      'user_id': userId,
      'name': name,
      'course_code': courseCode,
      'credit_hours': creditHours,
      'semester': semester,
      'teacher_name': teacherName,
    });
  }

  // সব courses fetch করো
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseClientService.from('courses')
        .select()
        .eq('user_id', userId)
        .order('semester', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  // Semester অনুযায়ী courses fetch করো
  static Future<List<Map<String, dynamic>>> getCoursesBySemester(
    String semester,
  ) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return [];

    final data = await SupabaseClientService.from('courses')
        .select()
        .eq('user_id', userId)
        .eq('semester', semester)
        .order('credit_hours', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Single course fetch করো
  static Future<Map<String, dynamic>?> getCourse(String courseId) async {
    return await SupabaseClientService.from('courses')
        .select()
        .eq('id', courseId)
        .maybeSingle();
  }

  // Course update করো
  static Future<void> updateCourse({
    required String courseId,
    required String name,
    required String courseCode,
    required double creditHours,
    required String semester,
    String? teacherName,
  }) async {
    await SupabaseClientService.from('courses').update({
      'name': name,
      'course_code': courseCode,
      'credit_hours': creditHours,
      'semester': semester,
      'teacher_name': teacherName,
    }).eq('id', courseId);
  }

  // Course delete করো
  static Future<void> deleteCourse(String courseId) async {
    await SupabaseClientService.from('courses')
        .delete()
        .eq('id', courseId);
  }

  // Career অনুযায়ী preset courses এবং topics অ্যাড করো
  static Future<void> setupCareerPresets(String careerGoal) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    // Normalize career goal string (e.g., "Flutter Developer" -> "flutter_developer")
    final normalizedGoal = careerGoal.toLowerCase().replaceAll(' ', '_');

    // 1. Get all template courses for this career
    final presetCourses = await SupabaseClientService.from('career_template_courses')
        .select()
        .eq('career_goal', normalizedGoal)
        .order('order_index', ascending: true);

    Map<String, String> templateTopicToUserTopic = {};

    for (var preset in presetCourses) {
      // Already আছে কিনা check করো
      final existing = await SupabaseClientService.from('courses')
          .select()
          .eq('user_id', userId)
          .eq('course_code', preset['course_code']);

      if ((existing as List).isNotEmpty) continue;

      // 2. Insert course for user
      final newCourse = await SupabaseClientService.from('courses').insert({
        'user_id': userId,
        'name': preset['course_name'],
        'course_code': preset['course_code'],
        'credit_hours': preset['credit_hours'],
        'semester': 'Semester 1',
        'is_career_relevant': true,
      }).select().single();

      // 3. Get template topics for this course
      final presetTopics = await SupabaseClientService.from('career_template_topics')
          .select()
          .eq('template_course_id', preset['id'])
          .order('order_index', ascending: true);

      for (var topic in presetTopics) {
        // 4. Insert topic for user
        final insertedTopic = await SupabaseClientService.from('topics').insert({
          'user_id': userId,
          'course_id': newCourse['id'],
          'name': topic['name'],
          'difficulty': topic['difficulty'],
          'estimated_hours': topic['estimated_hours'],
          'is_career_relevant': true,
          'is_completed': false,
        }).select().single();
        
        templateTopicToUserTopic[topic['id'].toString()] = insertedTopic['id'].toString();
      }
    }

    // 5. Setup prerequisites
    if (templateTopicToUserTopic.isNotEmpty) {
      final templateTopicIds = templateTopicToUserTopic.keys.toList();
      
      final allTemplatePrereqs = await SupabaseClientService.from('career_template_prerequisites')
          .select()
          .filter('topic_id', 'in', templateTopicIds);

      for (var prereq in allTemplatePrereqs) {
        final userTopicId = templateTopicToUserTopic[prereq['topic_id'].toString()];
        final userPrereqId = templateTopicToUserTopic[prereq['prerequisite_id'].toString()];

        if (userTopicId != null && userPrereqId != null) {
          await SupabaseClientService.from('topic_prerequisites').insert({
            'topic_id': userTopicId,
            'prerequisite_id': userPrereqId,
          });
        }
      }
    }
  }
}
