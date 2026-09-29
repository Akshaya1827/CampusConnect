import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder(
        stream: NotificationService.getMyNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data =
              notification.data() as Map<String, dynamic>;

              final isRead = data['isRead'] ?? false;

              return ListTile(
                leading: Icon(
                  isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                ),
                title: Text(
                  data['title'] ?? 'Notification',
                  style: TextStyle(
                    fontWeight:
                    isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  data['message'] ?? '',
                ),
                onTap: () async {
                  if (!isRead) {
                    await NotificationService.markAsRead(
                      notification.id,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}