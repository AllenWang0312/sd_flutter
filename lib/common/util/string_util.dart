
const List<String> SUPPORT_IMAGE_TYPES = ['.jpg',".jpeg",".gif",".png",'.webp'];



String appendCommaIfNotExist(String str) {
  if (str.isEmpty || str.endsWith(",") || str.endsWith("，")) {
    return str;
  } else {
    return "$str,";
  }
}

String appendPNGExtIfNotExist(String str) {
  if (str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[0])
      || str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[1])
      || str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[2])
      || str.toLowerCase().endsWith(SUPPORT_IMAGE_TYPES[3])
  ) {
    return str;
  } else {
    return "$str.png";
  }
}