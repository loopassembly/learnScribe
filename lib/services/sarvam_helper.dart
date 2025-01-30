import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class SarvamSpeechToText {
  static Future<String> transcribeAudio({
    required File audioFile,
    required String apiKey,
    required String languageCode,
    String model = 'saarika:v2',
  }) async {
    // Create multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.sarvam.ai/speech-to-text'),
    );

    // Add headers
    request.headers['api-subscription-key'] = apiKey;

    // Add audio file
    final mimeType = lookupMimeType(audioFile.path) ?? 'audio/*';
    final audioPart = await http.MultipartFile.fromPath(
      'file',
      audioFile.path,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(audioPart);

    // Add form fields
    request.fields['language_code'] = languageCode;
    request.fields['model'] = model;

    // Send request
    final response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print(responseBody);
      // Assuming the response is JSON with a 'text' field
      // You might need to adjust this based on the actual API response format
      return responseBody; // Or parse JSON and extract text
    } else {
      final errorBody = await response.stream.bytesToString();
      throw Exception(
          'Request failed with status ${response.statusCode}: $errorBody');
    }
  }
}
