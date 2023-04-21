

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/tavern/bean/Showable.dart';

import '../../../common/android.dart';

const TAG = "ImageInfo";
abstract class ImageInfo extends Showable{
  String? name;

  String? url;
  String? _fileMD5;
  String? _exif;
  String? localPath;

  File get file => File(getLocalPath());



  String getLocalPath() {
    localPath ??= "$ANDROID_APP_DOWNLOAD_DIR/$name";
    return localPath!;
  }

  setLocalPath(String value) {
    localPath = value;
  }
  Future<String?> getExif(File image) async {
    var path = getLocalPath();
    if (null == _exif) {
      File prompt =
      File('${path.substring(0, path.lastIndexOf('.'))}txt');

      bool isPng = path.toLowerCase().endsWith('.png');
      if (isPng) {
        _exif = await getPngExt(image, prompt);
      } else {
        _exif = await getOtherExt(image, prompt);
      }
    }
    return _exif;
  }


  Future<String?> getPngExt(File image, File prompt) async {
    if (prompt.existsSync()) {
      return await prompt.readAsString();
    } else {
      var bytes = await image.readAsBytes();
      try {
        String? ext = getPNGExtData(bytes);
        if (null != ext && ext.isNotEmpty) {
          prompt.createSync(recursive: true, exclusive: true);
          prompt.writeAsString(ext, encoding: utf8);
          return Future.value(ext);
        } else {
          return Future.error('');
        }
      } catch (e) {
        return Future.error(e.toString());
      }
    }
  }

  Future<String?> getOtherExt(File image, File prompt) async {
    if (prompt.existsSync()) {
      return await prompt.readAsString();
    } else {
      // var bytes = await image.readAsBytes();
      var exif = await readExifFromFile(image);
      // printExifOfBytes(bytes);
      logt(TAG, "jpeg exif:$exif");
      // logt(TAG, "jpeg exif:${}");
      // String tag = utf8.decode(exif[EXIF_IMAGE_KEYWORDS_KEY]!
      //     .values
      //     .toList()
      //     .map((e) => e as int)
      //     .toList());
      // info?.ageLevel = getAgeLevel(tag);
      // prompt.createSync(recursive: true, exclusive: true);
      // prompt.writeAsString(exif.toString()!, encoding: utf8);
      return exif.keys.length==0?null:'';
    }
  }

  @override
  String? getPrompts() {
    return _exif;
  }

  @override
  String getFileLocation() {
    return url??localPath??"";
  }

  String getFileMD5(Uint8List data) {
    _fileMD5 ??= md5.convert(data).toString();
    return _fileMD5!;
  }
}
