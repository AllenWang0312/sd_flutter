import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../sd/android.dart';
import '../sd/http_service.dart';
import 'util/string_util.dart';

final String TAG = "third_util";

Future<bool> checkStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    return Future.value(true);
  }
  return Future.error(false);
}

dynamic saveUrlToLocal(String url, String fileName, String path) async {
  path = removeAndroidPrePathIfIsPublic(path);
  fileName = appendPNGExtIfNotExist(fileName);
  if (isAndroidAbsPath(path)) {
    logt(TAG, "download $url : $path/$fileName");
    return download(url, "$path/$fileName");
  } else {
    logt(TAG, "saveBytesToLocal $url $path $fileName");

    return await saveBytesToLocal(await getBytesWithDio(url), fileName, path);
  }
  // SaverGallery.saveImage(
  //     imageBytes, name: name, androidExistNotSave: androidExistNotSave)
  // return Future.error('no date');
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
  } else {
    Fluttertoast.showToast(msg: "没有图像数据,无法保存",gravity: ToastGravity.CENTER);
    return Future.error("no data");
  }
}
