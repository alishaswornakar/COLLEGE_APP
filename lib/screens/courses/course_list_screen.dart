import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: courseProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: courseProv.courses.length,
              itemBuilder: (context, index) {
                final c = courseProv.courses[index];
                return ListTile(
                  title: Text(c['courseName'] ?? c['courseCode'] ?? 'Unnamed'),
                  subtitle: Text(c['department'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(courseId: c['id']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({required this.courseId, super.key});

  @override
  Widget build(BuildContext context) {
    // For brevity, fetch details via provider method or service
    return Scaffold(
      appBar: AppBar(title: const Text('Course Details')),
      body: Center(child: Text('Course details for $courseId')),
    );
  }
}