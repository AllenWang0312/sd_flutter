import 'package:sd/common/util/file_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:universal_platform/universal_platform.dart';

const int PATH_TYPE_APP_PRIVATE = 0;
const int PATH_TYPE_HIDE = 1;
const int PATH_TYPE_PUBLIC = 2;

class Workspace {
  static String TABLE_NAME = 'workspaces';
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY, name TEXT,pathType INTEGER,recordCount INTEGER,imageCount INTEGER";

  Workspace(
    String dynamicPath,
      this.name,{
    this.recordCount,
    this.imageCount,
  }){
    this._dynamicPath = dynamicPath;
  }

  Workspace.fromJson(dynamic json,String dynamicPath) {
    id = json['id'];
    name = json['name'];
    _dynamicPath = dynamicPath;

    pathType = json['pathType'];

    recordCount = json['recordCount'];
    imageCount = json['imageCount'];
  }

  int? id;
  String name = '';
  String _dynamicPath="";
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
    map['pathType'] = pathType;
    map['recordCount'] = recordCount;
    map['imageCount'] = imageCount;
    return map;
  }

  String get dirPath {
    return "$_dynamicPath";
  }
  String get absPath{
    return "$_dynamicPath/$name";
  }

  String getDesc() {
   if(UniversalPlatform.isAndroid)
     return removeAndroidPrePathIfIsPublic(dirPath);
   if(UniversalPlatform.isAndroid)
     return absPath.substring(absPath.indexOf('/Library'));
   return dirPath;
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
