import 'package:flutter/material.dart';
import '../../services/attendance_service.dart';

class AttendanceReportPage extends StatefulWidget {
  final String courseId;
  const AttendanceReportPage({required this.courseId, super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  final AttendanceService _service = AttendanceService();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _records = await _service.getAttendanceForCourse(widget.courseId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, i) {
                final r = _records[i];
                return ListTile(
                  title: Text(r['studentId'] ?? ''),
                  subtitle: Text('Present: ${r['present'] ?? false}'),
                  trailing: Text('${r['markedAt'] ?? ''}'),
                );
              },
            ),
    );
  }
}