

import 'package:sd/sd/const/config.dart';
import 'package:sd/common/util/file_util.dart';


const String ANDROID_PICTURES = "/Pictures";
const String ANDROID_ROOT_DIR = "/storage/emulated/0";

const String ANDROID_DOWNLOAD_DIR = "$ANDROID_ROOT_DIR/Download";

const String ANDROID_DATA = "${ANDROID_ROOT_DIR}/Android/data";
const String ANDROID_PRIVATE_FILE_PATH = "$ANDROID_DATA/$PACKAGE_NAME/files";
//Collections
const String ANDROID_PRIVATE_FILE_COLLECTIONS_PATH = "$ANDROID_PRIVATE_FILE_PATH/Collections";
const String ANDROID_PRIVATE_FILE_STYLES_PATH = "$ANDROID_PRIVATE_FILE_PATH/Styles";
const String ANDROID_PRIVATE_FILE_WORKSPACE_PATH = "$ANDROID_PRIVATE_FILE_PATH/Workspace";

const String ANDROID_PUBLIC_DOWNLOAD_PATH = "$ANDROID_DOWNLOAD_DIR/$APP_DIR_NAME";

const String ANDROID_PUBLIC_PICTURES_PATH = "$ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME";
const String ANDROID_PUBLIC_PICTURES_DOWNLOAD = "$ANDROID_PUBLIC_PICTURES_PATH/download";
const String ANDROID_PUBLIC_PICTURES_NOMEDIA = "$ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME/nomedia";


isAndroidAbsPath(String path) {
  return path.startsWith(ANDROID_ROOT_DIR);
}

String removeAndroidPrePathIfIsPublic(String path) {
  if(path.startsWith(
      // ANDROID_ROOT_DIR
      "$ANDROID_ROOT_DIR/Pictures"
  )){
    path = path.substring(ANDROID_ROOT_DIR.length);
  }
  return path;
}
