import 'dart:convert';

import 'package:sd/sd/bean/db/ImageRawData.dart';
import 'package:sd/sd/bean/file/UniqueSign.dart';
import 'package:sd/sd/mocker.dart';
import '../const/config.dart';

class GenerateResultItem extends UniqueSign with ImageRawData {
  GenerateResultItem({
    this.name = '',
    String data = '',
    this.isFile,}){
    this.data = base64Decode(data.substring(BASE64_PREFIX.length));
  }

  GenerateResultItem.fromJson(dynamic json) {
    name = json['name'];
    _data = json['data'];
    isFile = json['is_file'];
  }

  String? _data;
  bool? isFile;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['data'] = _data;
    map['is_file'] = isFile;
    return map;
  }

  @override
  String getFileLocation() {
    return nameToUrl(name??"");
  }
}