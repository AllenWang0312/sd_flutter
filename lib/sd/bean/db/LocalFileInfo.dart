import 'dart:io';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/db/ImageRawData.dart';

import '../../../common/util/file_util.dart';
import '../../../common/util/string_util.dart';
import '../file/UniqueSign.dart';

const TAG = "FileInfo";

class LocalFileInfo  extends UniqueSign with ImageRawData{


  LocalFileInfo? parent;
  String? name;

  File get file => File(localPath);
  String? _localPath;
  String get localPath{
    _localPath ??= "${getCollectionsPath()}/$name";
    return _localPath!;
  }

  setLocalPath(String value) {
    _localPath = value;
  }


  int? id;
  String? dirDes;
  int? _fileCount;
  LocalFileInfo? cover;
  List<LocalFileInfo>? images;

  int? get fileCount {
    if (_fileCount == null || _fileCount! < 0) {
      Directory dir = Directory(localPath);
      if (dir.existsSync()) {
        List<FileSystemEntity> files = dir.listSync().where((element) {
          return SUPPORT_IMAGE_TYPES.contains(getFileExt(element.path));
        }).toList();
        images = files
            .map((e) =>
            LocalFileInfo(name: getFileName(e.path), parent: this, absPath: e.path))
            .toList();
        _fileCount = images?.length;
        cover = (null != images && images!.isNotEmpty) ? images!.first : null;
      } else {
        _fileCount = -1;
      }
    }
    return _fileCount!;
  }

  String get iconFilePath => "$_localPath/favicon.ico";
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
    _isDir ??= FileSystemEntity.isDirectorySync(localPath);
    return _isDir!;
  }


  bool _isExist = false;

  bool get isExist {
    if (!_isExist) {
      _isExist = isDir
          ? Directory(localPath).existsSync()
          : File(localPath).existsSync();
    }
    return _isExist;
  }


  LocalFileInfo(
      {this.parent, String? name, String? url, bool? isDir, String? absPath}) {
    this.name = name;
    _isDir = isDir;

    _localPath = absPath;

    if(null!=_isDir&&_isDir!){
      dirDes = url;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocalFileInfo &&
              runtimeType == other.runtimeType &&
              _localPath == other._localPath;


  static LocalFileInfo fromFile(File newFile) {
    String absPath = newFile.path;
    return LocalFileInfo(name: getFileName(absPath), isDir: false, absPath: absPath);
  }

  @override
  String getFileLocation() {
   return localPath;
  }



}
