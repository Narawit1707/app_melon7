import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<dynamic> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index; // อัปเดตดัชนีของรูปภาพปัจจุบัน
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${widget.imageUrls.length}', // แสดงดัชนีรูปภาพปัจจุบัน
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}