import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/notification_model.dart';
import 'package:flutter_application_2/services/supabase_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      notifications = await SupabaseService.getNotificationsForUser();
    } catch (e) {
      // ignore
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  title: Text(n.message),
                  subtitle: Text(n.createdAt.toLocal().toString()),
                  trailing: n.read
                      ? null
                      : const Icon(Icons.fiber_new, color: Colors.red),
                  onTap: () async {
                    if (!n.read) {
                      await SupabaseService.markNotificationRead(n.id);
                      setState(() => n.read = true);
                    }
                  },
                );
              },
            ),
    );
  }
}
