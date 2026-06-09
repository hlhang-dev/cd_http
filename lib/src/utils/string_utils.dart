import 'dart:math';

class StringUtils {
  static String getRandomStr({int length = 16}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return List.generate(
      length,
          (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}