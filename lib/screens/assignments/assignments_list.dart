import 'package:flutter/material.dart';
import '../../services/assignment_service.dart';

class AssignmentsList extends StatelessWidget {
  final String courseId;
  const AssignmentsList({required this.courseId, super.key});

  @override
  Widget build(BuildContext context) {
    final service = AssignmentService();

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.assignmentsStream(courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: \\${snapshot.error}'));
          final assignments = snapshot.data ?? [];
          if (assignments.isEmpty) return const Center(child: Text('No assignments'));
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, i) {
              final a = assignments[i];
              return ListTile(
                title: Text(a['title'] ?? 'Untitled'),
                subtitle: Text(a['description'] ?? ''),
                onTap: () {
                  Navigator.pushNamed(context, '/assignments/submit', arguments: a['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}