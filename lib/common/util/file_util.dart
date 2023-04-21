import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;

import '../android.dart';
import '../../sd/config.dart';
import '../../sd/http_service.dart';

const TAG = "file util";

// String getPublicPicturesPath(){
//   if(UniversalPlatform.isWeb){
//     return "/";
//   }else if(UniversalPlatform.isAndroid){
//     return ANDROID_PUBLIC_PICTURES_PATH;
//   }else{
//     return "/$APP_DIR_NAME/Pictures";
//   }
// }
// Future<String> getPublicStylesPath()async{
//   return "${await getAutoSaveAbsPath()}/styles";
// }
const EXIF_IMAGE_EXIF_OFFSET_KEY = 'Image ExifOffset';
const EXIF_IMAGE_KEYWORDS_KEY = 'Image XPKeywords';
const EXIF_IMAGE_PADDING_KEY = 'Image Padding';
const EXIF_EXIF_PADDING_KEY = 'EXIF Padding';

String? getPNGExtData(Uint8List bytes) {
  var chunks = pngExtract.extractChunks(bytes);
  var scanChunkName = "tEXt";
  for (Map chunk in chunks) {
    for (String key in chunk.keys) {
      if (chunk[key].toString() == scanChunkName) {
        return String.fromCharCodes(chunk['data']);
      }
    }
  }
  return null;
}

// todo splash 初始化时固定到字段
Future<String> getImageAutoSaveAbsPath() async {
  if (UniversalPlatform.isWeb) {
    return "/$APP_DIR_NAME";
  }
  Directory? dir;

  if (UniversalPlatform.isAndroid) {
    dir = await getExternalStorageDirectory();
    if (null != dir) {
      return "${dir.path}/Pictures";
    } else {
      return ANDROID_PUBLIC_PICTURES_PATH;
    }
  } else if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
    dir = await getLibraryDirectory();
    if (null != dir) {
      return "${dir.path}/$APP_DIR_NAME";
    } else {
      return dir.path + "/Caches";
    }
  } else {
    dir = await getDownloadsDirectory();
    if (null != dir) {
      return "${dir.path}/$APP_DIR_NAME";
    } else {
      return "/$PACKAGE_NAME";
    }
  }
}

Future<String> getStylesAbsPath() async {
  if (UniversalPlatform.isWeb) {
    return "/$APP_DIR_NAME/styles";
  } else if (UniversalPlatform.isAndroid) {
    Directory? dir = await getExternalStorageDirectory();
    if (null != dir) {
      return "${dir.path}/styles";
    } else {
      return "$ANDROID_PUBLIC_PICTURES_PATH/styles";
    }
  } else if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
    Directory dir = await getApplicationDocumentsDirectory();
    if (null != dir) {
      return "${dir.path}/$APP_DIR_NAME";
    } else {
      return dir.path + "/styles";
    }
  }
  return "/$PACKAGE_NAME/styles";
}

bool createDirIfNotExit(String dirPath) {
  Directory dir = Directory(dirPath);
  if (!dir.existsSync()) {
    try {
      dir.createSync(recursive: true);
    } catch (e) {
      logt(TAG, e.toString());
    }
  }
  return dir.existsSync();
}

String getFileName(String absPath) {
  return absPath.substring(absPath.lastIndexOf("/") + 1);
}

String getFileExt(String absPath) {
  return absPath.substring(absPath.lastIndexOf('.')).toLowerCase();
}

bool createFileIfNotExit(File file) {
  if (!file.existsSync()) {
    try {
      file.createSync(recursive: true, exclusive: true); //递归 独占
    } catch (e) {
      logt(TAG, e.toString());
    }
  }
  return file.existsSync();
}
