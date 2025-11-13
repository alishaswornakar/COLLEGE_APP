import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';

class AddEditCoursePage extends StatefulWidget {
  final String? courseId;
  const AddEditCoursePage({this.courseId, super.key});

  @override
  State<AddEditCoursePage> createState() => _AddEditCoursePageState();
}

class _AddEditCoursePageState extends State<AddEditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _code = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _instructor = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _credits = TextEditingController();
  final TextEditingController _description = TextEditingController();
  int _semester = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _instructor.dispose();
    _department.dispose();
    _credits.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final prov = context.read<CourseProvider>();
    final ok = await prov.addCourse(
      _code.text.trim(),
      _name.text.trim(),
      _instructor.text.trim(),
      int.tryParse(_credits.text) ?? 3,
      _department.text.trim(),
      _semester,
      _description.text.trim(),
    );
    setState(() => _isLoading = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseId == null ? 'Add Course' : 'Edit Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _code, decoration: const InputDecoration(labelText: 'Course Code'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Course Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _instructor, decoration: const InputDecoration(labelText: 'Instructor')),
              const SizedBox(height: 12),
              TextFormField(controller: _department, decoration: const InputDecoration(labelText: 'Department')),
              const SizedBox(height: 12),
              TextFormField(controller: _credits, decoration: const InputDecoration(labelText: 'Credits'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [const Text('Semester:'), const SizedBox(width: 8), DropdownButton<int>(value: _semester, items: List.generate(8, (i) => i+1).map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(), onChanged: (v) => setState(() => _semester = v ?? 1))]),
              const SizedBox(height: 12),
              TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _isLoading ? null : _save, child: _isLoading ? const CircularProgressIndicator() : const Text('Save'))),
            ],
          ),
        ),
      ),
    );
  }
}