import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(String userId, String text, List<String> imageUrls) async {
    await FirebaseFirestore.instance.collection('posts').add({
      'userId': userId,
      'text': text,
      'imageUrls': imageUrls,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPosts() {
    return _firestore.collection('posts').orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> likePost(String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    await postRef.update({
      'likes': FieldValue.increment(1),
    });
  }
}