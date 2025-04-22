import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsSection extends StatelessWidget {
  final String postId;
  final String postOwnerId;

  const CommentsSection({super.key, required this.postId, required this.postOwnerId});

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
                final commentId = comments[index].id;
                final username = comment['username'] ?? 'Anonymous';
                final profileImageUrl = comment['profileImageUrl'];
                final content = comment['content'] ?? '';
                final currentUser = FirebaseAuth.instance.currentUser;

                final isCommentOwner = currentUser?.uid == comment['userId'];
                final isPostOwner = currentUser?.uid == postOwnerId;

                return GestureDetector(
                  onLongPress: () => _showCommentOptions(
                    context,
                    postId,
                    commentId,
                    content,
                    isCommentOwner,
                    isPostOwner,
                  ),
                  child: ListTile(
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

  void _showCommentOptions(
    BuildContext context,
    String postId,
    String commentId,
    String currentContent,
    bool isCommentOwner,
    bool isPostOwner,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            if (isCommentOwner)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCommentDialog(context, postId, commentId, currentContent);
                },
              ),
            if (isCommentOwner || isPostOwner)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteComment(context, postId, commentId);
                },
              ),
          ],
        );
      },
    );
  }

  void _showEditCommentDialog(
    BuildContext context,
    String postId,
    String commentId,
    String currentContent,
  ) {
    final editController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Edit your comment',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newContent = editController.text.trim();
                if (newContent.isEmpty) return;

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .doc(commentId)
                    .update({'content': newContent});

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(BuildContext context, String postId, String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    }
  }
}