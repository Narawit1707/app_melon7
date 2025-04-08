import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> searchUsers(String query) async {
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> searchPosts(String query) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('head', isGreaterThanOrEqualTo: query)
        .where('head', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs;
  }
}