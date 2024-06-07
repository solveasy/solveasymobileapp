import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'api_constants.dart';

class ApiService {
  static Future<void> uploadImageAndFetchResponse(
      File file, Future<void> Function(String) sendImageToMathpix) async {
    final uri = Uri.parse(UPLOAD_IMAGE_URL);
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(
        'content', file.path,
        filename: path.basename(file.path), contentType: MediaType('image', 'png')));
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var jsonResponse = jsonDecode(responseData.body);
      if (jsonResponse['path'] != null) {
        String imagePath = jsonResponse['path'];
        String fullImageUrl = BASE_URL + imagePath;
        await sendImageToMathpix(fullImageUrl);
      } else {
        print('Upload successful, but no path found in response.');
      }
    } else {
      print('Upload failed! Status code: ${response.statusCode}');
    }
  }

  static Future<String?> sendImageToMathpix(String imageUrl,
      Function showNoQuestionBottomSheet) async {
    final uri = Uri.parse(MATHPIX_URL);
    var headers = {
      'app_id': MATHPIX_APP_ID,
      'app_key': MATHPIX_APP_KEY,
      'Content-Type': 'application/json',
    };
    var body = jsonEncode({
      'src': imageUrl,
      'formats': ['text'],
      'include_line_data': true,
    });
    var response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['text'] != null) {
        String extractedText = jsonResponse['text'];
        return extractedText;
      } else {
        print('No text field found in Mathpix response.');
        showNoQuestionBottomSheet();
      }
    } else {
      print('Mathpix API request failed! Status code: ${response.statusCode}');
    }
    return null;
  }

  static Future<String?> sendTextToConversationApi(String message) async {
    final uri = Uri.parse(CONVERSATION_API_URL);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': CONVERSATION_API_KEY,
    };
    var body = jsonEncode({
      'message': message,
      'name': '',
    });
    var response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse != null) {
        return jsonResponse['content'] ?? 'No response';
      } else {
        print('No valid response from Conversation API.');
      }
    } else {
      print('Conversation API request failed! Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    return null;
  }
}