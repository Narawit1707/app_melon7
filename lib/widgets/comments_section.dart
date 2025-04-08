import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsSection extends StatelessWidget {
  final String postId;

  const CommentsSection({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No comments yet');
            }

            final comments = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index].data() as Map<String, dynamic>;
                final username = comment['username'] ?? 'Anonymous';
                final profileImageUrl = comment['profileImageUrl'];
                final content = comment['content'] ?? '';
                final createdAt = comment['createdAt'] != null
                    ? (comment['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final formattedTime =
                    '${createdAt.day}/${createdAt.month}/${createdAt.year}';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(content),
                  trailing: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final content = commentController.text.trim();
                if (content.isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final userData = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                final comment = {
                  'userId': user.uid,
                  'username': userData['username'] ?? 'Anonymous',
                  'profileImageUrl': userData['profileImageUrl'],
                  'content': content,
                  'createdAt': FieldValue.serverTimestamp(),
                };

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .add(comment);

                commentController.clear();
              },
            ),
          ],
        ),
      ],
    );
  }
}