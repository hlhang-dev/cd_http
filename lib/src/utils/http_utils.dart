import '../management/token_management.dart';

class HttpUtils {
  static Future<Map<String, dynamic>> buildHeader(
      Map<String, dynamic> globalHeaders,
      Map<String, dynamic>? headers,
      ) async {
    final token = await TokenManagement.getInstance().getToken();

    return {
      if (token != null && token.isNotEmpty) 'authorization': token,
      ...globalHeaders,
      if (headers != null) ...headers,
    };
  }
}