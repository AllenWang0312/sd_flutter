import 'dart:convert';
import 'dart:typed_data';

import '../http_service.dart';
import '../mocker.dart';

String TAG = "UserInfo";
class UserInfo {
  String? name;
  int age = 30;

  // Uint8List? _preview;

  // Uint8List get preview{
  //   if(_preview!=null){
  //     _preview = base64Decode(
  //         protrait.substring(BASE64_PREFIX.length));
  //     logt(TAG," preview data length ${_preview!.length}");
  //   }
  //   return _preview!;
  // }

  String protrait = '';


}
