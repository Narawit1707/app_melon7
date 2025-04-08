import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _postTextController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 10 images.')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitPost() async {
    final postText = _postTextController.text.trim();

    if (postText.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add text or images to your post.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

// ดึง username ของผู้โพสต์

    // TODO: อัปโหลดรูปภาพไปยัง Cloudinary หรือ Firebase Storage
    final imageUrls = []; // เพิ่ม URL ของรูปภาพที่อัปโหลด

    final post = {
      'userId': user.uid,
      'username': user.displayName ?? 'Anonymous', // บันทึก username
      'content': postText,
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

    setState(() {
      _postTextController.clear();
      _selectedImages.clear();
    });

    Navigator.of(context).pop(); // กลับไปหน้าโฮม
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.lime,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField สำหรับเขียนโพสต์
            TextField(
              controller: _postTextController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Write something...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // แสดงรูปภาพที่เลือก
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedImages
                  .map((image) => Stack(
                        children: [
                          Image.file(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.remove(image);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            // ปุ่มเพิ่มรูปภาพ
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Image'),
            ),
            const SizedBox(height: 16),
            // ปุ่มโพสต์
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