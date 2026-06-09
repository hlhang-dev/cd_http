import '../beans/http_config.dart';
import 'http_service.dart';

class HttpInit {
  static HttpInit? _instance;

  HttpInit._();

  static HttpInit getInstance() {
    _instance ??= HttpInit._();
    return _instance!;
  }

  void init(HttpConfig config) {
    HttpService.getInstance().init(config);
  }
}