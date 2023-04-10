

import 'package:sd/sd/config.dart';

const String ANDROID_ROOT_DIR = "/storage/emulated/0/";

const String ANDROID_PUBLIC_PICTURES_PATH = "${ANDROID_ROOT_DIR}Pictures/$APP_DIR_NAME";

isAndroidAbsPath(String path) {
  return path.startsWith(ANDROID_ROOT_DIR);
}

String removeAndroidPrePathIfIsPublic(String path) {
  if(path.startsWith("${ANDROID_ROOT_DIR}Pictures")){
    path = path.substring(ANDROID_ROOT_DIR.length);
  }
  return path;
}
