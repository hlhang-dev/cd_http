import 'package:dio/dio.dart';

import '../beans/upload_item.dart';
import '../core/http_exception.dart';
import '../core/http_service.dart';
import '../handler/upload_progress_listener.dart';
import '../utils/http_utils.dart';
import '../utils/string_utils.dart';
import '../management/token_management.dart';

class UploadFileService {
  UploadFileService._();

  static Future<UploadItem> uploadFile(
      UploadItem uploadFileItem,
      String url, {
        String token = '',
        String key = 'file',
        Map<String, dynamic>? data,
        Map<String, dynamic>? header,
        UploadProgressListener? progressListener,
      }) async {
    final currentAuthToken = await TokenManagement.getInstance().getToken();

    uploadFileItem.id = StringUtils.getRandomStr();

    if (uploadFileItem.isUpload) {
      return uploadFileItem;
    }

    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        key: await MultipartFile.fromFile(uploadFileItem.localPath),
      });

      final response = await HttpService.getInstance().dio.post(
        url,
        data: formData,
        options: Options(
          headers: await HttpUtils.buildHeader(
            {},
            {
              if (token.isNotEmpty) 'authorization': token,
              if (token.isEmpty &&
                  currentAuthToken != null &&
                  currentAuthToken.isNotEmpty)
                'authorization': currentAuthToken,
              if (header != null) ...header,
            },
          ),
        ),
        onSendProgress: (sent, total) {
          progressListener?.onProgress(sent, total);
        },
      );

      uploadFileItem.serverData = response.data;
      uploadFileItem.isUpload = true;

      return uploadFileItem;
    } on DioException catch (e) {
      throw HttpException('upload file item error: ${e.message}');
    } catch (e) {
      throw HttpException('upload file item error: $e');
    }
  }

  static Future<List<UploadItem>> uploadFiles(
      List<UploadItem> uploadFileList,
      String url, {
        String token = '',
        String key = 'file',
        Map<String, dynamic>? data,
        Map<String, dynamic>? header,
        void Function(int index, int sent, int total)? onSendProgress,
      }) async {
    if (uploadFileList.isEmpty) {
      throw HttpException('upload file list is empty');
    }

    for (int i = 0; i < uploadFileList.length; i++) {
      await uploadFile(
        uploadFileList[i],
        url,
        token: token,
        key: key,
        data: data,
        header: header,
        progressListener: _UploadProgressListenerAdapter(
          onProgressCallback: (sent, total) {
            onSendProgress?.call(i, sent, total);
          },
        ),
      );
    }

    return uploadFileList;
  }

  static Future<Response<dynamic>> downloadFile(
      String url,
      String savePath, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? header,
        void Function(int received, int total)? onReceiveProgress,
      }) async {
    try {
      return await HttpService.getInstance().dio.download(
        url,
        savePath,
        queryParameters: data,
        options: Options(
          headers: await HttpUtils.buildHeader(
            {},
            header,
          ),
        ),
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw HttpException('download file error: ${e.message}');
    } catch (e) {
      throw HttpException('download file error: $e');
    }
  }
}

class _UploadProgressListenerAdapter implements UploadProgressListener {
  final void Function(int current, int total) onProgressCallback;

  _UploadProgressListenerAdapter({
    required this.onProgressCallback,
  });

  @override
  void onProgress(int current, int total) {
    onProgressCallback(current, total);
  }
}