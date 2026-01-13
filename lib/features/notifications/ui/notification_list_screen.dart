import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationListScreen extends StatelessWidget {
  final String companyId;
  final String userId;
  final bool isAdmin;

  const NotificationListScreen({
    super.key,
    required this.companyId,
    required this.userId,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final NotificationService service = NotificationService();

    /// ✅ MARK ALL AS READ ONLY WHEN SCREEN OPENS
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isAdmin) {
        await service.markAllAdminNotificationsAsRead(
          companyId: companyId,
        );
      } else {
        await service.markAllEmployeeNotificationsAsRead(
          companyId: companyId,
          userId: userId,
        );
      }
    });

    final stream = isAdmin
        ? service.getAdminNotifications(companyId: companyId)
        : service.getEmployeeNotifications(
            companyId: companyId,
            userId: userId,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Notifications' : 'My Notifications'),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];

              return ListTile(
                leading: Icon(
                  n.read ? Icons.notifications_none : Icons.notifications,
                  color: n.read ? Colors.grey : Colors.blue,
                ),
                title: Text(n.title),
                subtitle: Text(n.message),
                trailing: n.read
                    ? null
                    : const Icon(Icons.circle, size: 10, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
