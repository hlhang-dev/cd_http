import '../management/token_management.dart';

class HttpUtils {
  static Map<String, dynamic> buildHeader(
      Map<String, dynamic> globalHeaders,
      Map<String, dynamic>? headers,
      ) {
    final token = TokenManagement.getInstance().getToken();

    return {
      if (token != null && token.isNotEmpty) 'authorization': token,
      ...globalHeaders,
      if (headers != null) ...headers,
    };
  }
}