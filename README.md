# cd_http

`cd_http` 是一个基于 `dio` 的轻量级 Flutter HTTP 封装，提供统一初始化、通用请求方法、业务响应解析、token 管理，以及文件上传下载能力。

## Features

- **统一初始化**
  - 通过 `HttpInit` 和 `HttpConfig` 统一配置 `baseUrl`、超时时间、全局请求头和业务字段映射。

- **统一请求入口**
  - 内置 `get`、`post`、`put`、`patch`、`delete` 方法。

- **统一业务结果处理**
  - 支持按后端返回结构解析 `code`、`msg`、`data`。
  - 支持未登录回调和业务错误回调。

- **UI 回调扩展**
  - 可接入 `loadingHandler` 与 `messageHandler`，统一处理加载状态和提示信息。

- **文件上传下载**
  - 支持单文件上传、多文件上传、下载和进度监听。

## Getting started

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  cd_http:
    path: ../cd_http
```

如果你是发布到私有源或 pub 仓库，请改成对应的版本引用方式。

## Usage

### 1. 初始化

先实现可选的加载和提示处理器：

```dart
import 'package:cd_http/cd_http.dart';

class AppLoadingHandler implements LoadingHandler {
  @override
  void show() {}

  @override
  void hide() {}
}

class AppMessageHandler implements MessageHandler {
  @override
  void show(String message) {}
}
```

然后在应用启动时初始化：

```dart
import 'package:cd_http/cd_http.dart';

void setupHttp() {
  HttpInit.getInstance().init(
    HttpConfig(
      baseUrl: 'https://api.example.com',
      header: const {
        'content-type': 'application/json',
      },
      loadingHandler: AppLoadingHandler(),
      messageHandler: AppMessageHandler(),
      successCode: 1,
      codeParamStr: 'code',
      successParamStr: 'code',
      serverMessageParamStr: 'msg',
      dataParamStr: 'data',
    ),
  );
}
```

### 2. 设置 token

```dart
TokenManagement.getInstance().setToken('Bearer your-token');
```

清除 token：

```dart
TokenManagement.getInstance().clearToken();
```

### 3. 发起请求

#### GET

```dart
final result = await HttpService.getInstance().get<Map<String, dynamic>>(
  '/user/profile',
  data: {
    'id': 1,
  },
);
```

#### POST

```dart
final result = await HttpService.getInstance().post<Map<String, dynamic>>(
  '/user/login',
  data: {
    'username': 'demo',
    'password': '123456',
  },
);
```

#### PATCH

```dart
final result = await HttpService.getInstance().patch<Map<String, dynamic>>(
  '/user/profile',
  data: {
    'nickname': 'river',
  },
);
```

#### 自定义模型解析

```dart
class UserProfile {
  final String name;

  UserProfile({required this.name});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(name: json['name'] as String);
  }
}

final user = await HttpService.getInstance().get<UserProfile>(
  '/user/profile',
  fromJsonT: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
);
```

### 4. 文件上传

```dart
final item = UploadItem(localPath: '/local/path/avatar.png');

await UploadFileService.uploadFile(
  item,
  '/upload/avatar',
  progressListener: _ProgressListener(),
);
```

```dart
class _ProgressListener implements UploadProgressListener {
  @override
  void onProgress(int current, int total) {}
}
```

### 5. 文件下载

```dart
await UploadFileService.downloadFile(
  '/files/manual.pdf',
  '/local/path/manual.pdf',
  onReceiveProgress: (received, total) {},
);
```

## Error handling

请求失败时会抛出 `HttpException`：

```dart
try {
  await HttpService.getInstance().get('/user/profile');
} on HttpException catch (e) {
  print(e.message);
}
```

当服务端返回未授权状态码时：

- **默认未授权码**
  - `401`
  - `403`

- **可配置行为**
  - 通过 `onUnauthorized` 统一处理登录失效场景。
  - 通过 `onBusinessError` 统一处理业务错误。

## Notes

- **初始化要求**
  - 调用任意请求前，必须先执行 `HttpInit.getInstance().init(...)`。

- **GET 参数**
  - `get()` 的 `data` 会作为 `queryParameters` 发送。

- **返回值**
  - 请求成功后，返回的是解析后的 `data` 字段，而不是完整响应体。