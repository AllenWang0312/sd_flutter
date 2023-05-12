
import 'package:sd/sd/bean/file/UniqueSign.dart';

const TAG = "ImageInfo";

mixin NetImage{

  String? url;

  // if (_sign == null) {
  // if (null != url) {
  // _sign = url!;
  // } else {
  // _sign = getFileMD5(data!); // fileSize hash for local  url for remote
  // }
  // }
  // return _sign!;





  @override
  String uniqueTag() {
    return url??"";
  }

  @override
  String getFileLocation() {
    return url??"";
  }




}
