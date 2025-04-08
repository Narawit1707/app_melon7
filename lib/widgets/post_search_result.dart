import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pj_app/service/search_service.dart';
import 'package:pj_app/pages/post_detail_page.dart';

class PostSearchResult extends StatelessWidget {
  final String searchQuery;

  const PostSearchResult({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: SearchService().searchPosts(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found'));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            final postId = posts[index].id;

            return ListTile(
              leading: post['imageUrls'] != null && (post['imageUrls'] as List).isNotEmpty
                  ? Image.network(
                      (post['imageUrls'] as List).first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image),
              title: Text(post['head'] ?? 'No Title'),
              subtitle: Text(post['content'] ?? 'No Content'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(postId: postId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}