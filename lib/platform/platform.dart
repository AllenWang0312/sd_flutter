import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:sd/sd/const/config.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:universal_platform/universal_platform.dart';

import '../common/third_util.dart';
import '../common/util/string_util.dart';
import '../sd/http_service.dart';

// export 'android.dart'
//   if(dart.library.html) 'ios.dart';
const String _ANDROID_ROOT_DIR = "/storage/emulated/0";
// const String _ANDROID_DATA = "${_ANDROID_ROOT_DIR}/Android/data";

// const String _ANDROID_PRIVATE_FILE_PATH = "$_ANDROID_DATA/$PACKAGE_NAME/files";

const String SYSTEM_DOWNLOAD_DIR = "$_ANDROID_ROOT_DIR/Download";
const String SYSTEM_DOWNLOAD_APP_PATH = "$SYSTEM_DOWNLOAD_DIR/$APP_DIR_NAME";

// const String PUBLIC_PICTURES_APP_PATH = "$_ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME";
// const String ANDROID_PUBLIC_PICTURES_NOMEDIA = "$_ANDROID_ROOT_DIR/Pictures/$APP_DIR_NAME/nomedia";

const TAG  ="Platform Android";

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


String syncPath = '';
String asyncPath = '';

const COLLECTIONS = "/Collections";

const WORKSPACES = "/Workspaces";
const STYLES = "/Styles";


String getCollectionsPath() => "$asyncPath/Collections";

String getWorkspacesPath() => "$asyncPath/Workspaces";

String getStylesPath() => "$syncPath/Styles";



dynamic saveUrlToLocal(String url,String fileName, String path,{String? domain}) async {
  path = removeAndroidPrePathIfIsPublic(path);//如果是picture下的文件夹，用galary saver 保存
  fileName = appendImageExtIfNotExist(domain,fileName);
  if (isAndroidAbsPath(path)) {
    return await download(url, "$path/$fileName",onReceiveProgress: (received,total){
      logt(TAG,"received:$received total:$total");
    });
  } else {
    logt(TAG, "saveBytesToLocal $url $path $fileName");
    return await saveBytesToLocal(await getBytesWithDio(url), fileName, path);
  }
  // SaverGallery.saveImage(
  //     imageBytes, name: name, androidExistNotSave: androidExistNotSave)
  // return Future.error('no date');
}


Future<String> saveBytesToLocal(Uint8List? bytes, String fileName, String path,
    {int quality = 100}) async {
  if (null != bytes && bytes.isNotEmpty) {
    path = removeAndroidPrePathIfIsPublic(path);
    if (isAndroidAbsPath(path)) {
      var file = File("$path/$fileName");
      // if(!file.existsSync()){
      file.createSync(recursive: true, exclusive: true);
      // }
      file.writeAsBytesSync(bytes);
      return Future.value("$path/$fileName");
    } else {
      if(UniversalPlatform.isIOS){
        dynamic result = await ImageGallerySaver.saveImage(bytes,
            quality: quality,
            name: fileName,
            isReturnImagePathOfIOS: true
        );

        if (result == null || result['isSuccess'] == false) {
          Fluttertoast.showToast(msg: "保存失败",gravity: ToastGravity.CENTER);
          return Future.error("save failed");
        } else {
          Fluttertoast.showToast(msg: "图像保存成功：${result['filePath']}");
          return Future.value(removeFilePreIfExist(result['filePath']));
        }
      }else{
        var result = await SaverGallery.saveImage(bytes,
            quality: quality,
            name: fileName,
            androidRelativePath: path,
            androidExistNotSave: false)
            .toString();
        if (result == null || result == '') {
          Fluttertoast.showToast(msg: "保存失败",gravity: ToastGravity.CENTER);
          return Future.error("save failed");
        } else {
          Fluttertoast.showToast(msg: "图像保存成功：$result");
          return Future.value("$path/$fileName");
        }
      }

    }
  } else {
    Fluttertoast.showToast(msg: "没有图像数据,无法保存",gravity: ToastGravity.CENTER);
    return Future.error("no data");
  }
}