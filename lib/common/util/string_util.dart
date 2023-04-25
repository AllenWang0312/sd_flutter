const List<String> SUPPORT_IMAGE_TYPES = [
  '.jpg',
  ".jpeg",
  ".gif",
  ".png",
  '.webp'
];

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
 if(str.isEmpty) return value;
 return str;
}

int toInt(String str, int value) {
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
