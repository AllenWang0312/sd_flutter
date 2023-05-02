import 'package:sd/sd/const/config.dart';

const String _ANDROID_ROOT_DIR = "/storage/emulated/0";
// const String _ANDROID_DATA = "${_ANDROID_ROOT_DIR}/Android/data";

// const String _ANDROID_PRIVATE_FILE_PATH = "$_ANDROID_DATA/$PACKAGE_NAME/files";

const String SYSTEM_DOWNLOAD_DIR = "$_ANDROID_ROOT_DIR/Download";
const String SYSTEM_DOWNLOAD_APP_PATH = "$SYSTEM_DOWNLOAD_DIR/$APP_DIR_NAME";

// const String PUBLIC_PICTURES_APP_PATH = "$_ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME";
// const String ANDROID_PUBLIC_PICTURES_NOMEDIA = "$_ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME/nomedia";

isAndroidAbsPath(String path) {
  return path.startsWith(_ANDROID_ROOT_DIR);
}

String removeAndroidPrePathIfIsPublic(String path) {
  if (path.startsWith(
      // ANDROID_ROOT_DIR
      "$_ANDROID_ROOT_DIR/Pictures")) {
    path = path.substring(_ANDROID_ROOT_DIR.length);
  }
  return path;
}
