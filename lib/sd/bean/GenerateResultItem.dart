import 'package:sd/sd/bean/Showable.dart';

import '../config.dart';

class GenerateResultItem extends Showable{
  GenerateResultItem({
      required this.name,
      this.data, 
      this.isFile,});

  GenerateResultItem.fromJson(dynamic json) {
    name = json['name'];
    data = json['data'];
    isFile = json['is_file'];
  }
  String name = "";
  dynamic? data;
  bool? isFile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['data'] = data;
    map['is_file'] = isFile;
    return map;
  }

  @override
  String getUrl() {
    return nameToUrl(name);
  }

}