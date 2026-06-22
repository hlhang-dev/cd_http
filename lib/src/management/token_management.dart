import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManagement {
  static TokenManagement? _instance;

  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  String? _token;

  TokenManagement._();

  static TokenManagement getInstance() {
    _instance ??= TokenManagement._();
    return _instance!;
  }

  Future<void> setToken(String token) async {
    _token = token;

    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }

    _token = await _storage.read(key: _tokenKey);
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;

    await _storage.delete(key: _tokenKey);
  }

  bool get hasTokenInMemory {
    return _token != null && _token!.isNotEmpty;
  }
}