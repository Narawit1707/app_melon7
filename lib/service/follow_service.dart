import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<bool> checkIfFollowing(String targetUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await _firestore.collection('users').doc(targetUserId).get();
      final followers = (userDoc.data()?['followers'] as List<dynamic>?) ?? [];
      return followers.contains(currentUser.uid);
    }
    return false;
  }

  Future<void> toggleFollow(String targetUserId, bool isFollowing) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef = _firestore.collection('users').doc(targetUserId);
      final currentUserRef = _firestore.collection('users').doc(currentUser.uid);

      if (isFollowing) {
        // เลิกติดตาม
        await userRef.update({
          'followers': FieldValue.arrayRemove([currentUser.uid]),
        });
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([targetUserId]),
        });
      } else {
        // ติดตาม
        await userRef.update({
          'followers': FieldValue.arrayUnion([currentUser.uid]),
        });
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([targetUserId]),
        });

        // ส่งการแจ้งเตือน
        final currentUsername = currentUser.displayName ?? 'Someone';
        await _notificationService.sendFollowNotification(targetUserId, currentUsername);
      }

      if (!isFollowing) {
        // ส่งการแจ้งเตือนเมื่อกดติดตาม
        final currentUsername = currentUser.displayName ?? 'Someone';
        await _notificationService.sendFollowNotification(targetUserId, currentUsername);
      }
    }
  }

  static Future<bool> isFollowing(String targetUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('followers')
        .doc(currentUser.uid)
        .get();

    final data = doc.data();
    if (data == null || !(data['following'] as List<dynamic>).contains(targetUserId)) {
      return false;
    }
    return true;
  }

  static Future<void> followUser(String targetUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final docRef = FirebaseFirestore.instance.collection('followers').doc(currentUser.uid);
    await docRef.set({
      'following': FieldValue.arrayUnion([targetUserId]),
    }, SetOptions(merge: true));

    // เพิ่มผู้ติดตามในโปรไฟล์ของเป้าหมาย
    final targetRef = FirebaseFirestore.instance.collection('followers').doc(targetUserId);
    await targetRef.set({
      'followers': FieldValue.arrayUnion([currentUser.uid]),
    }, SetOptions(merge: true));
  }

  static Future<void> unfollowUser(String targetUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final docRef = FirebaseFirestore.instance.collection('followers').doc(currentUser.uid);
    await docRef.update({
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    // ลบผู้ติดตามในโปรไฟล์ของเป้าหมาย
    final targetRef = FirebaseFirestore.instance.collection('followers').doc(targetUserId);
    await targetRef.update({
      'followers': FieldValue.arrayRemove([currentUser.uid]),
    });
  }

  Future<void> follow(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // เพิ่มผู้ใช้ใน followers ของ userId
    await _firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayUnion([currentUserId]),
    });

    // เพิ่ม userId ใน following ของ currentUser
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unfollow(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    // ลบผู้ใช้จาก followers ของ userId
    await _firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayRemove([currentUserId]),
    });

    // ลบ userId จาก following ของ currentUser
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([userId]),
    });
  }

  Future<bool> isUserFollowing(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final currentUserId = currentUser.uid;

    final userDoc = await _firestore.collection('users').doc(currentUserId).get(); // Renamed method
    final data = userDoc.data();

    if (data == null || data['following'] == null) return false;

    return (data['following'] as List<dynamic>).contains(userId);
  }
}