



import 'package:sd/android.dart';

const int PATH_TYPE_APP_PRIVATE = 0;
const int PATH_TYPE_HIDE = 1;
const int PATH_TYPE_PUBLIC = 2;

class Workspace {
  static String TABLE_NAME = 'workspaces';
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY, name TEXT,dirPath TEXT,pathType INTEGER,stylesConfigFilePath TEXT,recordCount INTEGER,imageCount INTEGER";

  Workspace(
    this.name,
    this.dirPath, {
    this.stylesConfigFilePath,
    this.recordCount,
    this.imageCount,
  });

  Workspace.fromJson(dynamic json) {
    name = json['name'];
    dirPath = json['dirPath'];
    pathType = json['pathType'];

    stylesConfigFilePath = json['stylesConfigFilePath'];
    recordCount = json['recordCount'];
    imageCount = json['imageCount'];
  }

  String name = '';
  String dirPath = '';
  int? pathType = 0;

  String? stylesConfigFilePath = null; //空 代表未设置  ‘’ 代表用远端
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
    map['name'] = name;
    map['dirPath'] = dirPath;
    map['pathType'] = pathType;
    map['stylesConfigFilePath'] = stylesConfigFilePath;
    map['recordCount'] = recordCount;
    map['imageCount'] = imageCount;
    return map;
  }

  String getDirPath() {
    return dirPath;
  }

  String getDesc() {
    return removeAndroidPrePathIfIsPublic(dirPath);

    // return '记录数：$recordCount, 图片数：$imageCount';
  }

  int getPathType() {
    if (pathType == null) {
      if (dirPath.startsWith('/Pictures')) {
        return PATH_TYPE_PUBLIC;
      } else if (dirPath.startsWith('/storage/emulated/0/Android/data/')) {
        return PATH_TYPE_APP_PRIVATE;
      } else {
        return PATH_TYPE_HIDE;
      }
    } else {
      return pathType!;
    }
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
}


