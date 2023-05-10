bool hasItem(List<PromptStyleFileConfig>? configs, String path) {
  if (null != configs && configs.isNotEmpty) {
    for (PromptStyleFileConfig item in configs) {
      if (item.configPath == path) {
        return true;
      }
    }
  }

  return false;
}

enum ConfigType {
  // 0 远端接口，1 自己独立配置文件 2 开放空间配置文件引用
  remote,
  private,
  public,
}

class PromptStyleFileConfig {
  static String TABLE_NAME = 'styles_file_config';

  static var TABLE_CREATE =
      'id INTEGER PRIMARY KEY,name TEXT,type INTEGER,belongTo INTEGER,fromConfigId INTEGER,rawPath TEXT';

  PromptStyleFileConfig({
    this.id,
    this.name = "default.dart",
    this.state = 0,
    this.type = 0,
    this.belongTo,
    this.fromConfigId,
    this.rawPath,
    String? dynamicPath,
  }){
  this._dynamicPath = dynamicPath;
  }

  int state = 0; // 0 公共配置 1 存在于当前workspace  -1 需要执行删除 2 需要执行添加

  PromptStyleFileConfig.fromJson(dynamic json,String? dynamicPath, {this.state = 0}) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    belongTo = json['belongTo'];
    fromConfigId = json['fromConfigId'];
    rawPath = json['rawPath'];
    _dynamicPath = dynamicPath;
  }

  int? id;
  String name = ""; // 默认 xxx的promptStyles
  String getName() {
    if (name.isEmpty && null != configPath && configPath.isNotEmpty) {
      name = configPath.substring(configPath.lastIndexOf('/') + 1);
    }
    return name;
  }

  late int type = 0;
  int? belongTo; // 属于某个workspace
  int? fromConfigId; // 原始数据源 本表id
  String? rawPath; // 原path 拷贝模式不需要存储
  String? _dynamicPath;

  String get configPath{
    return '$_dynamicPath/$name.csv';
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    map['belongTo'] = belongTo;
    map['fromConfigId'] = fromConfigId;
    map['rawPath'] = rawPath;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptStyleFileConfig &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          name == other.name;

  @override
  int get hashCode => state.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'PromptStyleFileConfig{state: $state, id: $id, name: $name, type: $type, belongTo: $belongTo}';
  }
}
