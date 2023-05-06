import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_platform/universal_platform.dart';

final String TAG = "third_util";

bool? _isMobile;
bool isMobile() {
  _isMobile??=UniversalPlatform.isAndroid || UniversalPlatform.isIOS;
  return _isMobile!;
}

Future<bool> checkStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    return Future.value(true);
  }
  return Future.error(false);
}



Future<Uint8List> getBytesWithDio(String url) async {
  var response =
      await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  return response.data;
}
Future<String> getStringWithDio(String url) async {
  var response =
  await Dio().get(url, options: Options(responseType: ResponseType.plain));
  return response.data;
}

