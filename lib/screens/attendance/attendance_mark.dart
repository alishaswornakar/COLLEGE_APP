import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';

class AttendanceMarkPage extends StatefulWidget {
  final String courseId;
  const AttendanceMarkPage({required this.courseId, super.key});

  @override
  State<AttendanceMarkPage> createState() => _AttendanceMarkPageState();
}

class _AttendanceMarkPageState extends State<AttendanceMarkPage> {
  final AttendanceService _service = AttendanceService();
  final TextEditingController _studentIdController = TextEditingController();
  bool _present = true;
  bool _isLoading = false;

  Future<void> _mark() async {
    if (_studentIdController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await _service.markAttendance(widget.courseId, _studentIdController.text, {
      'present': _present,
    });
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance marked')));
    _studentIdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            SwitchListTile(
              title: const Text('Present?'),
              value: _present,
              onChanged: (v) => setState(() => _present = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _mark,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Mark'),
            ),
          ],
        ),
      ),
    );
  }
}