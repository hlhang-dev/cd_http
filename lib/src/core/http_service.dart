import 'package:dio/dio.dart';

import '../beans/http_config.dart';
import '../beans/http_response.dart';
import '../definition/http_method.dart';
import '../utils/http_utils.dart';
import 'http_exception.dart';

class HttpService {
  static HttpService? _instance;

  late Dio _dio;

  Dio get dio => _dio;

  HttpConfig? _config;

  HttpService._();

  static HttpService getInstance() {
    _instance ??= HttpService._();
    return _instance!;
  }

  void init(HttpConfig config) {
    _config = config;

    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: config.header,
        responseType: ResponseType.json,
      ),
    );
  }

  Future<T?> get<T>(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? header,
    bool showLoading = true,
    T Function(dynamic json)? fromJsonT,
  }) {
    return doRequest<T>(
      url,
      method: HttpMethod.get,
      data: data,
      header: header,
      showLoading: showLoading,
      fromJsonT: fromJsonT,
    );
  }

  Future<T?> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? header,
    bool showLoading = true,
    T Function(dynamic json)? fromJsonT,
  }) {
    return doRequest<T>(
      url,
      method: HttpMethod.post,
      data: data,
      header: header,
      showLoading: showLoading,
      fromJsonT: fromJsonT,
    );
  }

  Future<T?> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? header,
    bool showLoading = true,
    T Function(dynamic json)? fromJsonT,
  }) {
    return doRequest<T>(
      url,
      method: HttpMethod.put,
      data: data,
      header: header,
      showLoading: showLoading,
      fromJsonT: fromJsonT,
    );
  }

  Future<T?> patch<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? header,
    bool showLoading = true,
    T Function(dynamic json)? fromJsonT,
  }) {
    return doRequest<T>(
      url,
      method: HttpMethod.patch,
      data: data,
      header: header,
      showLoading: showLoading,
      fromJsonT: fromJsonT,
    );
  }

  Future<T?> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? header,
    bool showLoading = true,
    T Function(dynamic json)? fromJsonT,
  }) {
    return doRequest<T>(
      url,
      method: HttpMethod.delete,
      data: data,
      header: header,
      showLoading: showLoading,
      fromJsonT: fromJsonT,
    );
  }

  Future<T?> doRequest<T>(
    String url, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? header,
    bool showLoading = true,
    T Function(dynamic json)? fromJsonT,
  }) async {
    final config = _config;

    if (config == null) {
      throw HttpException(
        'HttpService 未初始化，请先调用 HttpInit.getInstance().init()',
      );
    }

    final bool needShowLoading = config.isShowLoading && showLoading;
    final bool isGet = method == HttpMethod.get;

    try {
      if (needShowLoading) {
        config.loadingHandler?.show();
      }

      final response = await _dio.request(
        url,
        data: isGet ? null : data,
        queryParameters: isGet && data is Map<String, dynamic> ? data : null,
        options: Options(
          method: method.value,
          headers: await HttpUtils.buildHeader(config.header, header),
        ),
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw HttpException('服务端返回格式错误');
      }

      final httpResponse = HttpResponse<T>.fromJson(
        responseData,
        config,
        fromJsonT,
      );

      if (config.unauthorizedCodes.contains(httpResponse.code)) {
        config.onUnauthorized?.call();

        throw HttpException(
          httpResponse.msg.isEmpty ? '登录已失效，请重新登录' : httpResponse.msg,
          code: int.tryParse(httpResponse.code),
        );
      }

      if (!httpResponse.success) {
        if (httpResponse.msg.isNotEmpty) {
          config.messageHandler?.error(httpResponse.msg);
        }

        config.onBusinessError?.call(httpResponse.msg, httpResponse.code);

        throw HttpException(
          httpResponse.msg,
          code: int.tryParse(httpResponse.code),
        );
      }

      return httpResponse.result;
    } on DioException catch (e) {
      final message = _handleDioException(e);
      config.messageHandler?.error(message);
      throw HttpException(message);
    } finally {
      if (needShowLoading) {
        config.loadingHandler?.hide();
      }
    }
  }

  String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '请求超时';
      case DioExceptionType.receiveTimeout:
        return '响应超时';
      case DioExceptionType.badResponse:
        return '服务器异常：${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败';
      default:
        return '网络请求失败';
    }
  }
}