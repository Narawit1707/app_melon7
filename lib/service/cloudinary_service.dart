import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'dkg8udpsc'; // ใส่ Cloud Name ของคุณ
  final String apiKey = '462789626591915'; // ใส่ API Key ของคุณ
  final String apiSecret = 'SvCn6Jseasg3GixhHpb04coD1Ns'; // ใส่ API Secret ของคุณ

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dkg8udpsc/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'pj_app' // ใส่ Upload Preset ของคุณ
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final data = jsonDecode(responseData.body);
      return data['secure_url']; // URL ของรูปภาพที่อัปโหลด
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return null;
    }
  }
}