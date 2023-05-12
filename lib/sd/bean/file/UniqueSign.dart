

import 'package:sd/sd/bean/file/Showable.dart';



Map<String, Object?> toDynamic(String sign,int ageLevel){
  final map = <String, dynamic>{};
  map['sign'] = sign;
  map['ageLevel'] = ageLevel;
  return map;
}

abstract class UniqueSign extends Showable{
  static const TABLE_NAME = "age_level_record";
  static var TABLE_CREATE = 'id INTEGER PRIMARY KEY,sign TEXT UNIQUE,ageLevel INTEGER';

  String uniqueTag();

}