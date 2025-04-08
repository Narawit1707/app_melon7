import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pj_app/service/cloudinary_service.dart';

class WritePostPage extends StatefulWidget {
  final List<File> selectedImages;

  const WritePostPage({super.key, required this.selectedImages});

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _headController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> _submitPost() async {
    final head = _headController.text.trim();
    final content = _contentController.text.trim();

    if (head.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // แสดง Loading Indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      List<String> imageUrls = [];
      for (var image in widget.selectedImages) {
        final imageUrl = await _cloudinaryService.uploadImage(image);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
        }
      }

      final post = {
        'userId': user.uid,
        'username': user.displayName ?? 'Anonymous',
        'head': head,
        'content': content,
        'imageUrls': imageUrls,
        'likes': 0,
        'likedBy': [],
        'comments': [],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('posts').add(post);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully!')),
      );

      Navigator.of(context).pop(); // ปิด Loading Indicator
      Navigator.of(context).pop(); // กลับไปหน้าเลือกภาพ
      Navigator.of(context).pop(); // กลับไปหน้าโฮม
    } catch (e) {
      Navigator.of(context).pop(); // ปิด Loading Indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Write Post'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _headController,
              decoration: const InputDecoration(
                labelText: 'Head',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lime,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Post',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}