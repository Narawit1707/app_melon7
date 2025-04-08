import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pj_app/pages/edit_post_page.dart';
import 'package:pj_app/widgets/comments_section.dart';
import 'package:pj_app/widgets/image_carousel.dart'; // นำเข้า ImageCarousel
import 'package:pj_app/widgets/follow_button.dart'; // นำเข้า FollowButton

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Future<DocumentSnapshot?> _getUserData(String userId) async {
    try {
      return await FirebaseFirestore.instance.collection('users').doc(userId).get();
    } catch (e) {
      return null;
    }
  }

  Future<void> _toggleLike(String postId, bool isLiked) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    if (isLiked) {
      // ยกเลิกการกดไลค์
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      // กดไลค์
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post not found'));
          }

          final post = snapshot.data!.data() as Map<String, dynamic>;
          final postOwnerId = post['userId'] ?? '';

          return FutureBuilder<DocumentSnapshot?>(
            future: _getUserData(postOwnerId),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
              final username = userData?['username'] ?? 'Anonymous';

              final likes = post['likes'] ?? 0;
              final likedBy = (post['likedBy'] as List<dynamic>?) ?? [];
              final isLiked = likedBy.contains(FirebaseAuth.instance.currentUser?.uid);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post['imageUrls'] != null && (post['imageUrls'] as List).isNotEmpty)
                      ImageCarousel(imageUrls: post['imageUrls'] as List<dynamic>), // ใช้ ImageCarousel
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // เพิ่ม CircleAvatar สำหรับรูปโปรไฟล์
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: userData?['profileImageUrl'] != null
                                    ? NetworkImage(userData!['profileImageUrl'])
                                    : null,
                                child: userData?['profileImageUrl'] == null
                                    ? const Icon(Icons.person, size: 20)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              if (post['userId'] == FirebaseAuth.instance.currentUser?.uid)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPostPage(postId: widget.postId, post: post),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lime,
                                  ),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              if (post['userId'] != FirebaseAuth.instance.currentUser?.uid)
                                FollowButton(userId: post['userId']), // ใช้ FollowButton
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post['content'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.thumb_up,
                                  color: isLiked ? Colors.redAccent : Colors.grey,
                                ),
                                onPressed: () => _toggleLike(widget.postId, isLiked),
                              ),
                              Text('$likes likes'),
                            ],
                          ),
                          const Divider(),
                          CommentsSection(postId: widget.postId), // เพิ่มส่วนคอมเมนต์
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}