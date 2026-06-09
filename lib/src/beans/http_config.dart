import '../handler/loading_handler.dart';
import '../handler/message_handler.dart';

class HttpConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> header;

  final int successCode;
  final String codeParamStr;
  final String successParamStr;
  final String serverMessageParamStr;
  final String dataParamStr;
  final LoadingHandler? loadingHandler;
  final MessageHandler? messageHandler;
  final List<String> unauthorizedCodes;
  final void Function()? onUnauthorized;
  final void Function(String msg, String code)? onBusinessError;

  final bool isShowLoading;

  const HttpConfig({
    required this.baseUrl,
    this.loadingHandler,
    this.messageHandler,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.header = const {},
    this.successCode = 1,
    this.codeParamStr = 'code',
    this.successParamStr = 'code',
    this.serverMessageParamStr = 'msg',
    this.dataParamStr = 'data',
    this.isShowLoading = true,
    this.unauthorizedCodes = const ['401', '403'],
    this.onUnauthorized,
    this.onBusinessError,
  });
}