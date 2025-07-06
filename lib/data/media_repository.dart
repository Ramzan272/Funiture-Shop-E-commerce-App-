import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

class CloudinaryResponse {
  final bool isSuccessful;
  final String? secureUrl;
  final String? publicId;
  final CloudinaryError? error;
  final Map<String, dynamic>? data;

  CloudinaryResponse({
    required this.isSuccessful,
    this.secureUrl,
    this.publicId,
    this.error,
    this.data,
  });

  factory CloudinaryResponse.success({
    required String secureUrl,
    required String publicId,
    Map<String, dynamic>? data,
  }) {
    return CloudinaryResponse(
      isSuccessful: true,
      secureUrl: secureUrl,
      publicId: publicId,
      data: data,
    );
  }

  factory CloudinaryResponse.failure(String message) {
    return CloudinaryResponse(
      isSuccessful: false,
      error: CloudinaryError(message: message),
    );
  }
}

class CloudinaryError {
  final String message;

  CloudinaryError({required this.message});
}

class MediaRepository {
  static const String _cloudName = 'dgxwhwljv';
  static const String _apiKey = '588651978998343';
  static const String _apiSecret = 'hYs_d8SEob3Hkw75Qsztqy7KjAM';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  final ImagePicker _picker = ImagePicker();

  // Generate signature for authenticated uploads
  String _generateSignature(Map<String, String> params, String apiSecret) {
    // Sort parameters
    final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    // Create parameter string
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    // Add API secret
    final stringToSign = '$paramString$apiSecret';

    // Generate SHA1 hash
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  // Upload image from XFile (image picker result)
  Future<CloudinaryResponse> uploadImageFromXFile(XFile imageFile) async {
    try {
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        return await _uploadImageBytes(bytes, imageFile.name);
      } else {
        final file = File(imageFile.path);
        return await _uploadImageFile(file);
      }
    } catch (e) {
      print('Upload failed: $e');
      return CloudinaryResponse.failure('Upload failed: $e');
    }
  }

  // Upload image bytes (for web)
  Future<CloudinaryResponse> _uploadImageBytes(Uint8List bytes, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Parameters for signature
      final params = {
        'timestamp': timestamp,
        'folder': 'furniture_app', // Optional: organize uploads in folders
      };

      // Generate signature
      final signature = _generateSignature(params, _apiSecret);

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add the image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      // Add required parameters
      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      request.fields['folder'] = 'furniture_app';

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Cloudinary Response Status: ${response.statusCode}');
      print('Cloudinary Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return CloudinaryResponse.success(
          secureUrl: data['secure_url'],
          publicId: data['public_id'],
          data: data,
        );
      } else {
        final errorData = json.decode(responseBody);
        return CloudinaryResponse.failure(
            errorData['error']?['message'] ?? 'Upload failed with status ${response.statusCode}'
        );
      }
    } catch (e) {
      print('Network error during upload: $e');
      return CloudinaryResponse.failure('Network error: $e');
    }
  }
  Future<CloudinaryResponse> _uploadImageFile(File file) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final params = {
        'timestamp': timestamp,
        'folder': 'furniture_app',
      };
      final signature = _generateSignature(params, _apiSecret);

      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      request.fields['folder'] = 'furniture_app';

      print('Uploading file: ${file.path}');
      print('File size: ${await file.length()} bytes');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Cloudinary Response Status: ${response.statusCode}');
      print('Cloudinary Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return CloudinaryResponse.success(
          secureUrl: data['secure_url'],
          publicId: data['public_id'],
          data: data,
        );
      } else {
        final errorData = json.decode(responseBody);
        return CloudinaryResponse.failure(
            errorData['error']?['message'] ?? 'Upload failed with status ${response.statusCode}'
        );
      }
    } catch (e) {
      print('Network error during upload: $e');
      return CloudinaryResponse.failure('Network error: $e');
    }
  }

  Future<CloudinaryResponse?> pickAndUploadImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await uploadImageFromXFile(image);
      }

      return null;
    } catch (e) {
      print('Error picking and uploading image: $e');
      return CloudinaryResponse.failure('Error picking image: $e');
    }
  }
  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      final params = {
        'public_id': publicId,
        'timestamp': timestamp,
      };

      final signature = _generateSignature(params, _apiSecret);

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'api_key': _apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] == 'ok';
      }

      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get image picker instance
  ImagePicker get imagePicker => _picker;
}
