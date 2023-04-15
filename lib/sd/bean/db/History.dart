import 'package:sd/sd/bean/Showable.dart';

class History extends Showable {
  int? page;
  int? offset;

  static var TABLE_NAME = 'history';

  static var ORDER_BY_TIME = 'date,time';
  static var ORDER_BY_PATH = 'imgPath';

  static var TABLE_CREATE =
      'id INTEGER PRIMARY KEY, workspace TEXT,prompt TEXT,negativePrompt TEXT, seed INTEGER,width INTEGER,height INTEGER,date TEXT,time TEXT,errMsg TEXT,imgPath TEXT,imgUrl TEXT';
  String? prompt = '';
  String? negativePrompt = '';
  int ageLevel = 0;
  int? seed = -1;
  int? width = 512;
  int? height = 512;
  String? date = '';
  String? time = '';
  String? errMsg;
  String? imgPath = '';
  String? imgUrl;
  String? workspace = '';

  History({
    this.prompt,
    this.negativePrompt,
    this.ageLevel = 0,
    this.width,
    this.height,
    this.imgPath,
    this.date,
    this.time,
    this.seed,
    this.errMsg,
    this.imgUrl,
    this.page,
    this.offset,
    this.workspace,
  });

  History.fromJson(dynamic json) {
    prompt = json['prompt'];
    negativePrompt = json['negativePrompt'];
    seed = json['seed'];
    width = json['width'];
    height = json['height'];
    date = json['date'];
    time = json['time'];
    errMsg = json['errMsg'];
    imgPath = json['imgPath'];
    imgUrl = json['imgUrl'];
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
    map['imgPath'] = imgPath;
    map['imgUrl'] = imgUrl;
    map['workspace']=workspace;
    return map;
  }

  @override
  String getUrl() {
    return imgUrl ?? imgPath ?? "";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is History &&
          runtimeType == other.runtimeType &&
          imgPath == other.imgPath &&
          imgUrl == other.imgUrl;

  @override
  int get hashCode => imgPath.hashCode ^ imgUrl.hashCode;
}
