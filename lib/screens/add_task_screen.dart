import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
import '../Components/custom_button.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('What are you planning to study?'),
            SizedBox(height: 16.h),
            _buildInputField(
              controller: _taskController,
              hint: 'e.g. Graph Algorithms Revision',
              label: 'Task Title',
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _durationController,
                    hint: 'e.g. 2',
                    label: 'Duration (hrs)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildDatePicker(),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            CustomButton(
              content: 'Add to Schedule',
              width: double.infinity,
              onPressed: () {
                // Handle task addition logic here
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: const Color(0xFF4F200D), size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'New Study Task',
        style: GoogleFonts.interTight(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F200D),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.interTight(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4F200D),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF4F200D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.w),
              borderSide: const BorderSide(color: Color(0xFFFF9A00)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Date',
          style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {}, // Show Date Picker
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16.sp, color: const Color(0xFFFF9A00)),
                SizedBox(width: 8.w),
                Text(
                  'Oct 27, 2024',
                  style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF4F200D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
