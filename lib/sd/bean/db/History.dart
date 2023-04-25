import 'dart:typed_data';

import 'package:sd/sd/AIPainterModel.dart';
import '../../tavern/bean/UniqueSign.dart';

class History extends UniqueSign{
  int? page;
  int? offset;

  static var TABLE_NAME = 'history';

  static var ORDER_BY_TIME = 'date,time';
  static var ORDER_BY_PATH = 'imgPath';

  static var TABLE_CREATE =
      'id INTEGER PRIMARY KEY, workspace TEXT,prompt TEXT,negativePrompt TEXT, seed INTEGER,width INTEGER,height INTEGER,date TEXT,time TEXT,errMsg TEXT,imgPath TEXT,imgUrl TEXT';
  String? prompt = '';
  String? negativePrompt = '';
  int ageLevel = 18;
  int? seed = -1;
  int? width = 512;
  int? height = 512;
  String? date = '';
  String? time = '';
  String? errMsg;
  String? workspace = '';

  History({
    this.prompt,
    this.negativePrompt,
    this.ageLevel = 18,
    this.width,
    this.height,
    String? imgPath,
    this.date,
    this.time,
    this.seed,
    this.errMsg,
    String? imgUrl,
    this.page,
    this.offset,
    this.workspace,
  }){
    this.localPath = imgPath;
    this.url = imgUrl;
  }

  int getAgeLevel(AIPainterModel? provider, Uint8List? data) {
    return ageLevel;
  }
  History.fromJson(dynamic json) {
    prompt = json['prompt'];
    negativePrompt = json['negativePrompt'];
    seed = json['seed'];
    width = json['width'];
    height = json['height'];
    date = json['date'];
    time = json['time'];
    errMsg = json['errMsg'];
    localPath = json['imgPath'];
    url = json['imgUrl'];
    workspace = json['workspace'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['prompt'] = prompt;
    map['negativePrompt'] = negativePrompt;
    map['seed'] = seed;
    map['width'] = width;
    map['height'] = height;
    map['date'] = date;
    map['time'] = time;
    map['errMsg'] = errMsg;
    map['imgPath'] = localPath;
    map['imgUrl'] = url;
    map['workspace'] = workspace;
    return map;
  }

  @override
  String getFileLocation() {
    return url ?? localPath ?? "";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is History &&
          runtimeType == other.runtimeType &&
          localPath == other.localPath &&
          url == other.url;

  @override
  int get hashCode => localPath.hashCode ^ url.hashCode;

}
