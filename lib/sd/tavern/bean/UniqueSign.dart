

import 'dart:typed_data';

import '../../AIPainterModel.dart';
import 'ImageInfo.dart';

Map<String, Object?> toDynamic(String sign,int ageLevel){
  final map = <String, dynamic>{};
  map['sign'] = sign;
  map['ageLevel'] = ageLevel;
  return map;
}

abstract class UniqueSign  extends ImageInfo {

  String? sign;

  String getSign(Uint8List? data) {
    if (sign == null) {
      if (null != url) {
        sign = url!;
      } else {
        sign = getFileMD5(data!); // fileSize hash for local  url for remote
      }
    }
    return sign!;
  }

  int getAgeLevel(AIPainterModel provider, Uint8List? data) {
    return provider.limit[getSign(data)] ?? 0;
  }


  void setAgeLevel(AIPainterModel provider, int value) {
    if (value > 0) {
      provider.limit.putIfAbsent(sign!, () => value);
    } else {
      provider.limit.remove(sign);
    }
    provider.notifyListeners();
  }

}