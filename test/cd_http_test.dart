import 'package:flutter_test/flutter_test.dart';

import 'package:cd_http/cd_http.dart';
import 'package:cd_http/src/utils/http_utils.dart';

void main() {
  const defaultConfig = HttpConfig(baseUrl: 'https://example.com');

  tearDown(() {
    TokenManagement.getInstance().clearToken();
  });

  group('HttpResponse.fromJson', () {
    test('parses default response fields', () {
      final response = HttpResponse<Map<String, dynamic>>.fromJson(
        {
          'code': 1,
          'msg': 'ok',
          'data': {'name': 'river'},
        },
        defaultConfig,
        null,
      );

      expect(response.success, isTrue);
      expect(response.code, '1');
      expect(response.msg, 'ok');
      expect(response.result, {'name': 'river'});
    });

    test('supports custom data parser', () {
      final response = HttpResponse<int>.fromJson(
        {
          'code': 1,
          'msg': 'ok',
          'data': {'value': 42},
        },
        defaultConfig,
        (json) => (json as Map<String, dynamic>)['value'] as int,
      );

      expect(response.success, isTrue);
      expect(response.result, 42);
    });

    test('supports custom success field', () {
      const customConfig = HttpConfig(
        baseUrl: 'https://example.com',
        successParamStr: 'success',
      );

      final response = HttpResponse<String>.fromJson(
        {
          'success': true,
          'code': 200,
          'msg': 'ok',
          'data': 'done',
        },
        customConfig,
        null,
      );

      expect(response.success, isTrue);
      expect(response.code, '200');
      expect(response.result, 'done');
    });
  });

  group('TokenManagement and HttpUtils', () {
    test('stores and clears token', () {
      final tokenManagement = TokenManagement.getInstance();

      tokenManagement.setToken('Bearer token');
      expect(tokenManagement.getToken(), 'Bearer token');

      tokenManagement.clearToken();
      expect(tokenManagement.getToken(), isNull);
    });

    test('buildHeader merges token global and local headers', () {
      TokenManagement.getInstance().setToken('Bearer token');

      final headers = HttpUtils.buildHeader(
        {
          'x-global': '1',
          'content-type': 'application/json',
        },
        {
          'x-local': '2',
          'authorization': 'Bearer override',
        },
      );

      expect(headers['x-global'], '1');
      expect(headers['x-local'], '2');
      expect(headers['content-type'], 'application/json');
      expect(headers['authorization'], 'Bearer override');
    });

    test('buildHeader omits authorization when token is empty', () {
      final headers = HttpUtils.buildHeader(
        {'x-global': '1'},
        null,
      );

      expect(headers['x-global'], '1');
      expect(headers.containsKey('authorization'), isFalse);
    });
  });
}