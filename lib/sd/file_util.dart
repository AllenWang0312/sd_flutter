import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:universal_platform/universal_platform.dart';

import '../android.dart';
import 'config.dart';



Future<String> getAutoSaveAbsPath() async {
  if (UniversalPlatform.isWeb) {
    return "/$APP_DIR_NAME";
  }
  if (UniversalPlatform.isAndroid) {
    Directory? dir = await getExternalStorageDirectory();
    if (null != dir) {
      return "${dir.path}/Pictures";
    } else {
      return ANDROID_PUBLIC_PICTURES_PATH;
    }
  }
  return "/";
}

Future<String> getStylesAbsPath() async {
  if (UniversalPlatform.isWeb) {
    return "/$APP_DIR_NAME/styles";
  }
  if (UniversalPlatform.isAndroid) {
    // Directory? dir = await getExternalStorageDirectory();
    // if (null != dir) {
    //   return "${dir.path}/styles";
    // } else {
      return "$ANDROID_PUBLIC_PICTURES_PATH/styles";
    // }
  }
  return "/";
}


bool createDirIfNotExit(String dirPath) {
  Directory dir = Directory(dirPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir.existsSync();
}

bool createFileIfNotExit(String filePath) {
  File file = File(filePath);
  if (!file.existsSync()) {
    file.createSync(recursive: true,exclusive: true);
  }
  return file.existsSync();
}
