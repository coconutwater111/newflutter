import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class NetworkService {
  static const String baseUrl = 'https://1b39113ffc61.ngrok-free.app/api/submit';
  static const int maxRetries = 3;

  Future<Map<String, dynamic>> sendData(Map<String, dynamic> data) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          developer.log("成功送出：${response.body}");
          return {
            'success': true,
            'message': '✅ 成功送出：${response.body}',
            'retryCount': attempt,
          };
        } else {
          developer.log("錯誤：狀態碼 ${response.statusCode}");
          if (attempt == maxRetries) {
            return {
              'success': false,
              'message': '❌ 錯誤：狀態碼 ${response.statusCode}',
              'retryCount': attempt,
            };
          }
        }
      } catch (e) {
        developer.log("連線失敗：$e");
        if (attempt == maxRetries) {
          return {
            'success': false,
            'message': '🚫 無法連線伺服器，請稍後再試。',
            'retryCount': attempt,
          };
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    
    return {
      'success': false,
      'message': '🚫 連線失敗',
      'retryCount': maxRetries,
    };
  }
}