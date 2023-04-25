import 'package:sd/common/android.dart';
import 'package:universal_platform/universal_platform.dart';

const int PATH_TYPE_APP_PRIVATE = 0;
const int PATH_TYPE_HIDE = 1;
const int PATH_TYPE_PUBLIC = 2;

class Workspace {
  static String TABLE_NAME = 'workspaces';
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY, name TEXT,dirPath TEXT,pathType INTEGER,recordCount INTEGER,imageCount INTEGER";

  Workspace(
    this.name,
    String dirPath, {
    this.recordCount,
    this.imageCount,
  }){
    this._dirPath = dirPath;
  }

  Workspace.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    _dirPath = json['dirPath'];
    pathType = json['pathType'];

    recordCount = json['recordCount'];
    imageCount = json['imageCount'];
  }

  int? id;
  String name = '';
  String _dirPath = '';
  int? pathType = 0;

  int? recordCount;
  int? imageCount;

  String getName() {
    if (name.isEmpty) {
      return 'default';
    }
    return name;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['dirPath'] = _dirPath;
    map['pathType'] = pathType;
    map['recordCount'] = recordCount;
    map['imageCount'] = imageCount;
    return map;
  }

  String get dirPath {
    return "$_dirPath/$name";
  }

  String getDesc() {
    return removeAndroidPrePathIfIsPublic(dirPath);
    // return '记录数：$recordCount, 图片数：$imageCount';
  }

  int getPathType() {
    if (pathType == null) {
      // if (UniversalPlatform.isIOS || dirPath.startsWith(ANDROID_PICTURES)) {
      //   pathType = PATH_TYPE_PUBLIC;
      // } else if (dirPath.startsWith(ANDROID_DATA)) {
        pathType = PATH_TYPE_APP_PRIVATE;
      // } else {
      //   pathType = PATH_TYPE_HIDE;
      // }
    }
    return pathType!;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workspace &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dirPath == other.dirPath &&
          pathType == other.pathType;

  @override
  int get hashCode => name.hashCode ^ dirPath.hashCode ^ pathType.hashCode;

  @override
  String toString() {
    return 'Workspace{id: $id, name: $name, dirPath: $dirPath}';
  }
}
