
import 'dart:math';
import '../file/UniqueSign.dart';

 const SIZE_NAME = ['default', 'iphone', 'oneplus', 'tv'];
 const CHANG = [768, 1200, 1344, 1280];
 const KUAN = [512, 540, 621, 720];

class History extends UniqueSign{
  int? page;
  int? offset;

  static var TABLE_NAME = 'history';

  static var ORDER_BY_PATH = 'imgPath';

  static var TABLE_CREATE =
      'id INTEGER PRIMARY KEY, workspace TEXT,prompt TEXT,negativePrompt TEXT, seed INTEGER,width INTEGER,height INTEGER,sizeType INTEGER,date TEXT,time TEXT,errMsg TEXT,imgPath TEXT,imgUrl TEXT';

  String? prompt = '';
  String? negativePrompt = '';
  int ageLevel = 0;
  int? seed = -1;
  int? width = 512;
  int? height = 512;
  int? _sizeType = -1;

  String? date = '';
  String? time = '';
  String? errMsg;
  String? workspace = '';
  String? url;
  String? localPath = '';

  int promptStar = 0; //模型兼容度
  int bodyStar = 0; //形体
  int resStar = 0; //画质
  int envStar = 0; //环境融合度

  double avagerStar = 0.0;

  get sizeType{
    if(null==_sizeType||(_sizeType==-1&&width!=height)){
      _sizeType = CHANG.indexOf(max(width??512,height??512));
    }
    return _sizeType;
  }
  get sizeTypeName{
    return SIZE_NAME[sizeType];
  }

  History({
    this.prompt,
    this.negativePrompt,
    this.ageLevel = 18,
    this.width = 512,
    this.height = 512,
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
    _sizeType = json['sizeType'];
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
    map['sizeType'] = sizeType;
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

  @override
  String toString() {
    return 'History{localPath: $localPath, url:$url, page: $page, offset: $offset, prompt: $prompt, negativePrompt: $negativePrompt, ageLevel: $ageLevel, seed: $seed, width: $width, height: $height, date: $date, time: $time, errMsg: $errMsg, workspace: $workspace}';
  }

  @override
  String uniqueTag() {
    return localPath??url??"";
  }
}
