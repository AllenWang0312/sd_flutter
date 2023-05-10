import 'dart:math';

const List<String> SUPPORT_IMAGE_TYPES = [
  '.jpg',
  ".jpeg",
  ".gif",
  ".png",
  '.webp'
];

const FILE_PREFIX = 'file://';

RegExp getPluginMarch(String prefix, String name) {
return RegExp(r'<" + prefix + ":" + name + ":+([0-1]\.\d)>+');
}


bool allChinease(String str) {
  String cnMatches = r'[\\u4e00-\\u9fa5]+';
  return str.contains(RegExp(cnMatches));
}
String randomStr(int length){
  final random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
 return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String removeFilePreIfExist(String s) {
  if (s.startsWith(FILE_PREFIX)) {
    return s.substring(FILE_PREFIX.length);
  }
  return s;
}

String appendCommaIfNotExist(String str) {
  if (str.isEmpty || str.endsWith(",") || str.endsWith("，")) {
    return str;
  } else {
    return "$str,";
  }
}

String appendImageExtIfNotExist(String? domain, String str) {
  if (str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[0]) ||
      str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[1]) ||
      str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[2]) ||
      str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[3])) {
    return str;
  } else if (null != domain && domain.contains('pixai.art')) {
    return "$str.webp";
  } else {
    return "$str.jpeg";
  }
}

String withDefault(String str, String value) {
  if (str.isEmpty) return value;
  return str;
}

int toInt(dynamic str, int value) {
  if (str is int) {
    return str;
  }
  try {
    int result = int.parse(str);
    return result;
  } catch (e) {
    return value;
  }
}

double toDouble(String str, double value) {
  try {
    double result = double.parse(str);
    return result;
  } catch (e) {
    return value;
  }
}
