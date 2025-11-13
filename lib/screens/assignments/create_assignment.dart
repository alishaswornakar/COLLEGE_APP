import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _courseId = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _courseId.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final svc = AssignmentService();
    final ok = await svc.createAssignment({
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'courseId': _courseId.text.trim(),
    });
    setState(() => _isLoading = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4),
              const SizedBox(height: 12),
              TextFormField(controller: _courseId, decoration: const InputDecoration(labelText: 'Course ID'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const Spacer(),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: _isLoading ? null : _create, child: _isLoading ? const CircularProgressIndicator() : const Text('Create'))),
            ],
          ),
        ),
      ),
    );
  }
}