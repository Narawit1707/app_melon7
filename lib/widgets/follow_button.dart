import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowButton extends StatelessWidget {
  final String userId;

  const FollowButton({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const SizedBox(); // หากผู้ใช้ไม่ได้ล็อกอิน ให้แสดงพื้นที่ว่าง
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Loading...'),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final following = (data['following'] as List<dynamic>?) ?? [];
        final isFollowing = following.contains(userId);

        return ElevatedButton(
          onPressed: () async {
            try {
              if (isFollowing) {
                // ยกเลิกการติดตาม
                await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                  'following': FieldValue.arrayRemove([userId]),
                });
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'followers': FieldValue.arrayRemove([currentUser.uid]),
                });
              } else {
                // ติดตาม
                await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                  'following': FieldValue.arrayUnion([userId]),
                });
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'followers': FieldValue.arrayUnion([currentUser.uid]),
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.lime : Colors.lime,
          ),
          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
        );
      },
    );
  }
}