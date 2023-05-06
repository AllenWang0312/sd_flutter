import 'dart:async';
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

class FromTo {
  String from;
  String to;

  FromTo(this.from, this.to);
}


FutureOr<dynamic> moveDirToAnotherPath(FromTo fromTo) async {
  Directory pubPics = Directory(fromTo.from);
  Directory priPics = Directory(fromTo.to);

  List<FileSystemEntity> entitys = pubPics.listSync();
  try {
    for (FileSystemEntity entity in entitys) {
      if (entity is Directory) {
        await moveChildToAnotherPath(
            getFileName(entity.path), entity.listSync(), priPics);
      }
    }
    logt(TAG, "moveDirToAnotherPath Success");

    return Future.value(1);
  } catch (e) {
    logt(TAG, "moveDirToAnotherPath failed ${e.toString()}");

    return Future.error(-1);
  }
}

Future<void> moveChildToAnotherPath(String fileName,
    List<FileSystemEntity> listSync, Directory priPics) async {
  listSync.forEach((element) async {
    if (element is File) {
      String newPath =
          "${priPics.path}/$fileName/${getFileName(element.path)}";
      logt(TAG, "${element.path} $newPath");
      await element.copy(newPath);
      await element.delete();
    }
  });
}