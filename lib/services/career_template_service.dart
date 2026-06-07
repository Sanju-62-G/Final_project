import 'package:flutter/foundation.dart';
import 'supabase_client.dart';

class CareerTemplateService {
  static Future<void> loadCareerTemplate(String careerGoal) async {
    debugPrint('Loading template for: $careerGoal');
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) return;

    try {
      // Template courses fetch করো
      final templateCourses = await SupabaseClientService.from('career_template_courses')
          .select('''
            *,
            career_template_topics(
              *,
              career_template_prerequisites!topic_id(
                prerequisite_id
              )
            )
          ''')
          .eq('career_goal', careerGoal)
          .order('order_index', ascending: true);

      for (var templateCourse in templateCourses) {
        // Already আছে কিনা check করো
        final existing = await SupabaseClientService.from('courses')
            .select()
            .eq('user_id', userId)
            .eq('course_code', templateCourse['course_code']);

        if ((existing as List).isNotEmpty) continue;

        // Course add করো
        final course = await SupabaseClientService.from('courses')
            .insert({
              'user_id': userId,
              'name': templateCourse['course_name'],
              'course_code': templateCourse['course_code'],
              'credit_hours': templateCourse['credit_hours'],
              'semester': templateCourse['semester_suggestion'],
              'is_career_relevant': true,
            })
            .select()
            .single();

        List<Map<String, dynamic>> templateTopics =
            List<Map<String, dynamic>>.from(
                templateCourse['career_template_topics'] ?? []);

        // Topic id mapping
        Map<dynamic, dynamic> topicIdMap = {};

        // Topics add করো
        for (var templateTopic in templateTopics) {
          final topic = await SupabaseClientService.from('topics')
              .insert({
                'course_id': course['id'],
                'user_id': userId,
                'name': templateTopic['name'],
                'difficulty': templateTopic['difficulty'],
                'estimated_hours': templateTopic['estimated_hours'],
                'is_completed': false,
                'is_career_relevant': true,
                'completion_order': templateTopic['order_index'],
              })
              .select()
              .single();

          topicIdMap[templateTopic['id']] = topic['id'];
        }

        // Prerequisites add করো
        for (var templateTopic in templateTopics) {
          List prereqs = templateTopic['career_template_prerequisites'] ?? [];

          for (var prereq in prereqs) {
            final userTopicId = topicIdMap[templateTopic['id']];
            final userPrereqId = topicIdMap[prereq['prerequisite_id']];

            if (userTopicId != null && userPrereqId != null) {
              await SupabaseClientService.from('topic_prerequisites')
                  .insert({
                    'topic_id': userTopicId,
                    'prerequisite_id': userPrereqId,
                  });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading career template: $e');
      rethrow;
    }
  }
}
