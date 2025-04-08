import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePictureService {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadProfilePicture(
      BuildContext context, Function(String) onUploadSuccess) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        await uploadProfilePicture(context, imageFile, onUploadSuccess);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
// CLOUDINARY_URL=cloudinary://462789626591915:SvCn6Jseasg3GixhHpb04coD1Ns@dkg8udpsc
  Future<void> uploadProfilePicture(BuildContext context, File imageFile, Function(String) onUploadSuccess) async {
    try {
      // แสดง Loading Indicator
      showDialog(
        context: context,
        barrierDismissible: false, // ป้องกันการปิดโดยไม่ได้ตั้งใจ
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // URL สำหรับอัปโหลดไปยัง Cloudinary
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dkg8udpsc/image/upload');

      // สร้าง HTTP Request
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'pj_app' // ใส่ Upload Preset ที่ตั้งค่าไว้ใน Cloudinary
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // ส่ง Request
      final response = await request.send();

      // ปิด Loading Indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        final imageUrl = jsonResponse['secure_url'];

        // อัปเดต URL ใน Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'profileImageUrl': imageUrl,
          });
        }

        // เรียก callback เพื่ออัปเดต UI
        onUploadSuccess(imageUrl);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      // ปิด Loading Indicator หากเกิดข้อผิดพลาด
      Navigator.of(context).pop();
      throw Exception('Error uploading image: $e');
    }
  }

  void viewProfilePicture(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}