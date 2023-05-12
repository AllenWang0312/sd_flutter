
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

mixin ImageRawData{

  Uint8List? data;

  @override
  String uniqueTag() {
    if(data!=null){
      return dataMD5(data!);
    }else{
      return '';
    }
  }

  String? _dataMD5;


  String dataMD5(Uint8List data) {
    _dataMD5 ??= md5.convert(data).toString();
    return _dataMD5!;
  }

}