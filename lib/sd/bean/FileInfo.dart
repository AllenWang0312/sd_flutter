import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:sd/sd/model/AIPainterModel.dart';

import '../../common/util/file_util.dart';
import '../../common/util/string_util.dart';
import 'UniqueSign.dart';

const TAG = "FileInfo";





class FileInfo extends UniqueSign {
  static const TABLE_NAME = "age_level_record";
  static var TABLE_CREATE = 'id INTEGER PRIMARY KEY,sign TEXT UNIQUE,ageLevel INTEGER';

  FileInfo? parent;

  int? id;

  int? _fileCount;
  FileInfo? cover;
  List<FileInfo>? images;

  int? get fileCount {
    if (_fileCount == null || _fileCount! < 0) {
      Directory dir = Directory(getLocalPath());
      if (dir.existsSync()) {
        List<FileSystemEntity> files = dir.listSync().where((element) {
          return SUPPORT_IMAGE_TYPES.contains(getFileExt(element.path));
        }).toList();
        images = files
            .map((e) =>
            FileInfo(name: getFileName(e.path), parent: this, absPath: e.path))
            .toList();
        _fileCount = images?.length;
        cover = (null != images && images!.isNotEmpty) ? images!.first : null;
      } else {
        _fileCount = -1;
      }
    }
    return _fileCount!;
  }

  String get iconFilePath => "$localPath/favicon.ico";
  bool? _isDir;


  // int getAgeLevel(String decode) {
  //   logt(TAG, decode);
  //   if (decode.contains("1") && decode.contains("8")) {
  //     return 18;
  //   } else {
  //     return 0;
  //   }
  // }

  bool get isDir {
    _isDir ??= FileSystemEntity.isDirectorySync(getLocalPath());
    return _isDir!;
  }


  bool _isExist = false;

  bool get isExist {
    if (!_isExist) {
      _isExist = isDir
          ? Directory(getLocalPath()).existsSync()
          : File(getLocalPath()).existsSync();
    }
    return _isExist;
  }


  FileInfo(
      {this.parent, String? name, String? url, bool? isDir, String? absPath}) {
    this.name = name;
    _isDir = isDir;
    localPath = absPath;
    this.url = url;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FileInfo &&
              runtimeType == other.runtimeType &&
              localPath == other.localPath;


  static FileInfo fromFile(File newFile) {
    String absPath = newFile.path;
    return FileInfo(name: getFileName(absPath), isDir: false, absPath: absPath);
  }

}
