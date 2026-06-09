class TokenManagement {
  static TokenManagement? _instance;

  String? _token;

  TokenManagement._();

  static TokenManagement getInstance() {
    _instance ??= TokenManagement._();
    return _instance!;
  }

  void setToken(String token) {
    _token = token;
  }

  String? getToken() {
    return _token;
  }

  void clearToken() {
    _token = null;
  }
}