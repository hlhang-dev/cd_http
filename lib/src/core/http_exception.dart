class HttpException implements Exception {
  final int? code;
  final String message;

  HttpException(
      this.message, {
        this.code,
      });

  @override
  String toString() {
    return message;
  }
}