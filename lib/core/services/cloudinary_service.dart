import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // THAY ĐỔI CÁC GIÁ TRỊ NÀY BẰNG THÔNG TIN CỦA BẠN
  static const String cloudName = 'dhqymowso';
  static const String uploadPreset = 'auction_uploads';

  static const String apiUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Upload ảnh lên Cloudinary và trả về URL
  static Future<String> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Thêm file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Thêm upload preset (không cần API key vì dùng unsigned)
      request.fields['upload_preset'] = uploadPreset;

      // Thêm folder (tùy chọn)
      request.fields['folder'] = 'auction_app';

      // Upload
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonResponse = json.decode(responseString);

        // Trả về secure URL
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Upload thất bại: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi upload ảnh: ${e.toString()}');
    }
  }

  /// Xóa ảnh từ Cloudinary (cần API key - chỉ dùng khi cần)
  /// Lưu ý: Xóa ảnh yêu cầu signed request, nên thường làm từ backend
  static Future<void> deleteImage(String publicId) async {
    // Implement nếu cần xóa ảnh
    // Cần API Key và API Secret
    throw UnimplementedError('Delete image requires API credentials');
  }
}
