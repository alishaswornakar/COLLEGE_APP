import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = NotificationService();
    // For demo we'll use null user target - replace with actual uid if needed
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: svc.notificationsStream(''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: \\${snapshot.error}'));
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No notifications'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final n = items[i];
              return ListTile(
                title: Text(n['title'] ?? 'No title'),
                subtitle: Text(n['body'] ?? ''),
                trailing: Text(n['createdAt']?.toString() ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}