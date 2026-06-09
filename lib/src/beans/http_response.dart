import '../beans/http_config.dart';

class HttpResponse<T> {
  final bool success;
  final String code;
  final String msg;
  final T? result;

  HttpResponse({
    required this.success,
    required this.code,
    required this.msg,
    this.result,
  });

  factory HttpResponse.fromJson(
      Map<String, dynamic> json,
      HttpConfig config,
      T Function(dynamic json)? fromJsonT,
      ) {
    final dynamic successValue = json[config.successParamStr];

    return HttpResponse<T>(
      success: _parseSuccess(successValue, config.successCode),
      code: '${json[config.codeParamStr] ?? ''}',
      msg: '${json[config.serverMessageParamStr] ?? ''}',
      result: fromJsonT == null
          ? json[config.dataParamStr] as T?
          : fromJsonT(json[config.dataParamStr]),
    );
  }

  static bool _parseSuccess(dynamic value, int successCode) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
      return int.tryParse(value) == successCode;
    }

    if (value is num) {
      return value == successCode;
    }

    return false;
  }
}