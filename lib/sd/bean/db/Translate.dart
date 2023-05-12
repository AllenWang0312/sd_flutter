import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/db_controler.dart';

class Translate {
  static Map<String,String> transCache = Map();

  static const TABLE_NAME = "translate_zh";
  static const Columns = ['keyWords', 'type', 'year', 'translate'];

  static const TABLE_CREATE =
      'id INTEGER PRIMARY KEY,keyWords TEXT UNIQUE,type INTEGER,year INTEGER,translate TEXT';

  Translate.fromJson(dynamic json) {
    keyWords = json['keyWords'];
    translate = json['translate'];
    type = toInt(json['type'], 0);
    year = toInt(json['year'], 0);
  }

  String keyWords = '';
  String? translate;

  bool notFound = false;
  int type = 0;
  int year = 0;

  Translate(
      {this.keyWords = '', this.translate, this.type = 0, this.year = 0}) {
    keyWords = keyWords.trim();

    if (keyWords.isNotEmpty) {
      autoTranslate();
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['keyWords'] = keyWords;
    map['translate'] = translate;
    map['type'] = type;
    map['year'] = year;

    return map;
  }

  Future<void> autoTranslate() async {
    if (notFound == false && translate == null) {
      if (keyWords.contains(' ')) {
        translate='';
        keyWords.split(".").where((element) => element.isNotEmpty).toList().forEach((element) async {
          String trans = await findItem(element);
          if(trans.isNotEmpty)translate= translate! +'$trans ';
        });
        if(translate!.isNotEmpty){
          translate = translate!.trim();
        }else{
          notFound = true;
        }
      } else {
        translate = await findItem(keyWords);
        notFound = translate == '';
      }
    }
  }

  Future<String> findItem(String keyWords) async {
    List? result =
        await DBController.instance.queryTranslate(Columns[0], "%$keyWords%", 0, 1);
    if (null != result && result.length == 1) {
      String trans = result[0]['translate'];
      transCache.putIfAbsent(keyWords, () => trans);
      return trans;
    } else {
      return '';
    }
  }
}
