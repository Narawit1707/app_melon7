import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ส่งแจ้งเตือนเมื่อมีคนกดติดตาม
  Future<void> sendFollowNotification(String targetUserId, String followerUsername) async {
    await _firestore.collection('notifications').add({
      'userId': targetUserId, // ผู้ใช้ที่ได้รับการแจ้งเตือน
      'message': '$followerUsername started following you',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false, // สถานะการอ่าน
    });
  }

  // ดึงจำนวนแจ้งเตือนที่ยังไม่ได้อ่าน
  Future<int> getUnreadNotificationCount(String currentUserUid) async {
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUserUid)
        .where('read', isEqualTo: false)
        .get();

    return querySnapshot.docs.length;
  }

  // อัปเดตสถานะการอ่านของแจ้งเตือน
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> sendNotification({
    required String userId,
    required String type,
    required String message,
    String? postId,
    required String senderId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': type,
      'message': message,
      'postId': postId,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}

class NotificationList extends StatelessWidget {
  final String currentUserUid;

  NotificationList({required this.currentUserUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

            return ListTile(
              title: Text(message),
              subtitle: timestamp != null
                  ? Text('${timestamp.toLocal()}')
                  : null,
              trailing: notification['read'] == false
                  ? const Icon(Icons.circle, color: Colors.blue, size: 10)
                  : null,
              onTap: () {
                // Mark as read
                FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(notifications[index].id)
                    .update({'read': true});
              },
            );
          },
        );
      },
    );
  }
}