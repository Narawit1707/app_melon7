import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pj_app/service/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      return const Center(child: Text('Please log in to view notifications'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: currentUserUid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final message = notification['message'] ?? 'No message';
              final timestamp = (notification['timestamp'] as Timestamp?)?.toDate();
              final notificationId = notifications[index].id;

              return ListTile(
                title: Text(message),
                subtitle: timestamp != null
                    ? Text('${timestamp.toLocal()}')
                    : null,
                trailing: notification['read'] == false
                    ? const Icon(Icons.circle, color: Colors.blue, size: 10)
                    : null,
                onTap: () async {
                  // Mark notification as read
                  await _notificationService.markNotificationAsRead(notificationId);
                },
              );
            },
          );
        },
      ),
    );
  }
}