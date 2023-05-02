import 'dart:io';
import 'dart:typed_data';
import 'package:sd/sd/db_controler.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;
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
String getRemoteFileNameNoExtend(String domain,String url) {
  if(domain.contains('pixai.art')){//domain.contains('krea.ai')||
    return dbString(DateTime.now().toString());
  }
  return url.substring(url.lastIndexOf("/") + 1);
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
