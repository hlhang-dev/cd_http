class UploadItem {
  String id;
  String localPath;
  String networkPath;
  dynamic serverData;
  bool isUpload;

  UploadItem({
    this.id = '',
    required this.localPath,
    this.networkPath = '',
    this.serverData,
    this.isUpload = false,
  });
}