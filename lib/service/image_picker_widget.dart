import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  const ImagePickerWidget({super.key, required this.onImagesSelected});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<File> _images = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && _images.length < 10) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
      widget.onImagesSelected(_images);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _images
              .map((image) => Image.file(image, width: 100, height: 100, fit: BoxFit.cover))
              .toList(),
        ),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Add Image'),
        ),
      ],
    );
  }
}