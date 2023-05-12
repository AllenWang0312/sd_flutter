

import 'dart:io';

import 'package:sd/common/util/file_util.dart';

abstract class Showable {
  String? exif;

  String? getPrompts() {
    return exif;
  }
  Future<String?> getAndCacheExif(File image) async {
    if (null == exif) {
      File prompt = File('${getFileLocation().substring(0, getFileLocation().lastIndexOf('.'))}.txt');
      bool isPng = getFileLocation().toLowerCase().endsWith('.png');
      if (isPng) {
        exif = await getPngExt(image, prompt);
      } else {
        exif = await getOtherExt(image, prompt);
      }
    }
    return exif;
  }
  String getFileLocation();



}