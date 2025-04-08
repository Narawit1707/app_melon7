import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pj_app/service/search_service.dart';
import 'package:pj_app/pages/other_user_profile_page.dart';

class UserSearchResult extends StatelessWidget {
  final String searchQuery;

  const UserSearchResult({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: SearchService().searchUsers(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users = snapshot.data!;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user['profileImageUrl'] != null
                    ? NetworkImage(user['profileImageUrl'])
                    : null,
                child: user['profileImageUrl'] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user['username'] ?? 'No Username'),
              subtitle: Text(user['bio'] ?? 'No Bio'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserProfilePage(userId: userId),
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