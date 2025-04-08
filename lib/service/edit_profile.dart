import 'package:flutter/material.dart';

class EditProfileDialog extends StatelessWidget {
  final String currentUsername;
  final String currentBio;
  final Function(String, String) onSave;

  const EditProfileDialog({
    super.key,
    required this.currentUsername,
    required this.currentBio,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController =
        TextEditingController(text: currentUsername);
    final TextEditingController bioController =
        TextEditingController(text: currentBio);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TextField สำหรับแก้ไข Username
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          // TextField สำหรับแก้ไข Bio
          TextField(
            controller: bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // ปิด Dialog
          },
          child: const Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onSave(
              usernameController.text.trim(),
              bioController.text.trim(),
            ); // ส่งข้อมูลกลับไปยัง ProfilePage
            Navigator.of(context).pop(); // ปิด Dialog
          },
          child: const Text('Save'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.lime,
          ),
        ),
      ],
    );
  }
}