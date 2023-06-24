import 'package:sd/sd/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveStringMapToSP(
    SharedPreferences sp, Map<String, String> map, String key) async {
  await sp.setStringList(key + "_key", map.keys.toList());
  await sp.setStringList(key + "_value", map.values.toList());
}

void restoneStringMapFromSP(
    SharedPreferences sp, Map<String, String> map, String key) {
  var keys = sp.getStringList(key + "_key");
  var values = sp.getStringList(key + "_value");
  if (null != keys &&
      null != values &&
      keys.length > 0 &&
      keys.length == values.length) {
    for (int i = 0; i < keys.length; i++) {
      map.putIfAbsent(keys[i], () => values[i]);
    }
  }else{
    logt(TAG, "restone map faild "
        "keys :$keys"
        "values: $values");
  }
}

class SPUtil {}
