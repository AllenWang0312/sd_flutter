

import 'package:sd/sd/config.dart';
import 'package:sd/sd/file_util.dart';


const String ANDROID_PICTURES = "/Pictures";
const String ANDROID_ROOT_DIR = "/storage/emulated/0";
const String ANDROID_DATA = "${ANDROID_ROOT_DIR}/Android/data";
const String ANDROID_PRIVATE_FILE_PATH = "$ANDROID_DATA/$PACKAGE_NAME/files";

const String ANDROID_PUBLIC_PICTURES_PATH = "$ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME";
const String ANDROID_PUBLIC_PICTURES_NOMEDIA = "$ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME/nomedia";

// const String ANDROID_PUBLIC_DOCUMENTS_PATH = "$ANDROID_ROOT_DIR/Documents/$APP_DIR_NAME";

// const String ANDROID_PUBLIC_STYLES_PATH = "$ANDROID_PUBLIC_PICTURES_PATH/styles";

isAndroidAbsPath(String path) {
  return path.startsWith(ANDROID_ROOT_DIR);
}

String removeAndroidPrePathIfIsPublic(String path) {
  if(path.startsWith("$ANDROID_ROOT_DIR/Pictures")){
    path = path.substring(ANDROID_ROOT_DIR.length);
  }
  return path;
}
