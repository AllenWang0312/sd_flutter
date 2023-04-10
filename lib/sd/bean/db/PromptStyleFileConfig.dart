class PromptStyleFileConfig {
  static String TABLE_NAME = 'styles_file_config';

  static var TABLE_CREATE ='id INTEGER PRIMARY KEY,name TEXT,type INTEGER,belongTo INTEGER,fromConfigId INTEGER,rawPath TEXT,configPath TEXT';

  PromptStyleFileConfig({
    this.id,
    this.name,
    this.type = 0,
    this.belongTo,
    this.fromConfigId,
    this.rawPath,
    this.configPath,
  });

  PromptStyleFileConfig.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    belongTo = json['belongTo'];
    fromConfigId = json['fromConfigId'];
    rawPath = json['rawPath'];
    configPath = json['configPath'];
  }

  int? id;
  String? name; // 默认 xxx的promptStyles
  late int type = 0; // 0 远端接口，1 自己独立配置文件 2 开放空间配置文件 3 已有配置文件引用
  int? belongTo; // 属于某个workspace
  int? fromConfigId; // 原始数据源 本表id
  String? rawPath; // 原path 拷贝模式不需要存储
  String? configPath; // 现有path

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['type'] = type;
    map['belongTo'] = belongTo;
    map['fromConfigId'] = fromConfigId;
    map['rawPath'] = rawPath;
    map['configPath'] = configPath;
    return map;
  }
}
