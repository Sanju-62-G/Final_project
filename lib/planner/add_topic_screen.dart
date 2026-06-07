import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';
import '../services/topic_service.dart';

class AddTopicScreen extends StatefulWidget {
  final String courseId;
  final List<Map<String, dynamic>> existingTopics;
  
  const AddTopicScreen({
    super.key, 
    required this.courseId,
    this.existingTopics = const [],
  });

  @override
  State<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends State<AddTopicScreen> {
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();
  String _difficulty = 'Medium';
  final List<String> _selectedPrereqs = [];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Add Topic', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF4F200D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('Topic Name', 'e.g. Recursion', _nameController),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(child: _buildDifficultyPicker()),
                SizedBox(width: 16.w),
                Expanded(child: _buildInputField('Est. Hours', 'e.g. 4', _hoursController, keyboardType: TextInputType.number)),
              ],
            ),
            SizedBox(height: 24.h),
            Text('Prerequisites', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp)),
            SizedBox(height: 12.h),
            _buildPrereqList(),
            SizedBox(height: 40.h),
            CustomButton(
              content: 'Save Topic',
              width: double.infinity,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: const BorderSide(color: Color(0xFFFFD93D))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: const BorderSide(color: Color(0xFFFFD93D))),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.sp)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.w), border: Border.all(color: const Color(0xFFFFD93D))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _difficulty,
              isExpanded: true,
              items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _difficulty = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrereqList() {
    if (widget.existingTopics.isEmpty) {
      return Text('No other topics found to set as prerequisites', style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey));
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: widget.existingTopics.map((topic) {
        final id = topic['id'].toString();
        final isSelected = _selectedPrereqs.contains(id);
        return FilterChip(
          label: Text(topic['name']),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedPrereqs.add(id);
              } else {
                _selectedPrereqs.remove(id);
              }
            });
          },
          selectedColor: const Color(0xFFFF9A00).withValues(alpha: 0.2),
          checkmarkColor: const Color(0xFFFF9A00),
        );
      }).toList(),
    );
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty || _hoursController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      await TopicService.addTopic(
        courseId: widget.courseId,
        name: _nameController.text.trim(),
        difficulty: _difficulty.toLowerCase(),
        estimatedHours: double.parse(_hoursController.text),
        prerequisites: _selectedPrereqs,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
