// const PROMPT_KEY = 'Prompt:';
import 'package:sd/common/bean/StringIndicator.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/const/SDConst.dart';
import 'package:sd/sd/const/default.dart';
import 'package:sd/sd/http_service.dart';

class Configs {
  static const String TAG = "Prompt";

  String prompt = '';
  String negativePrompt = '';

  int steps = DEFAULT_SAMPLER_STEPS;
  double weight = 6.0;



  String sampler = DEFAULT_SAMPLER;
  double cfgScale = 7.0;
  int seed = -1;
  String modelHash = '';
  String _size = '512x768';
  int XValue = 0;
  int YValue = 0;
  int ZValue = 0;


  set size(String value) {
    _size = value;
    var sizes = value.split('x');
    width = int.parse(sizes[0]);
    height = int.parse(sizes[1]);
  }

  int width = DEFAULT_WIDTH;
  int height = DEFAULT_HEIGHT;

  @override
  String toString() {
    return '$prompt'
        '$NEGATIVE_KEY$negativePrompt'
        '$STEPS_KEY $steps, $SAMPLER_KEY $sampler, $CFG_KEY $cfgScale, $SEED_KEY $seed, $MODEL_HASH_KEY $modelHash, $SIZE_KEY ${_size ?? '$width x$height'}';
  }

  static StringIndicator? nextAvailable(
      List<StringIndicator> indicators, int index) {
    for (int i = index + 1; i < indicators.length; i++) {
      if (indicators[i].start != -1) {
        return indicators[i];
      }
    }
    return null;
  }

  Configs updateConfigs(String prompt) {
    List<StringIndicator> indicators = KEYS
        .map((e) {
          int start = prompt.indexOf(e);
          int end = start + e.length;
          return StringIndicator(e, start, end);
        })
        .where((element) => element.start > 0)
        .toList()
      ..sort((a, b) => a.start - b.start);
    logt(TAG, indicators.toString());

    Configs result = Configs();
    result.prompt = withDefault(substring(prompt, indicators, index: -1), '');
    result.negativePrompt =
        withDefault(substring(prompt, indicators, key: NEGATIVE_KEY), '');
    result.steps = toInt(substring(prompt, indicators, key: STEPS_KEY), 30);
    result.sampler = withDefault(
        substring(prompt, indicators, key: SAMPLER_KEY), this.sampler);
    result.cfgScale =
        toDouble(substring(prompt, indicators, key: CFG_KEY), 7.0);
    result.seed = toInt(substring(prompt, indicators, key: SEED_KEY), -1);
    result.modelHash = withDefault(
        substring(prompt, indicators, key: MODEL_HASH_KEY), this.modelHash);
    // result.modelHash = prompt.substring(
    //     indicators[5].end + 1, nextAvailable(indicators, 5)?.start - 2);
    // result.size = prompt.substring(indicators[6].end + 1);
    logt(TAG, result.toString());
    return result;
  }

  static String substring(String prompt, List<StringIndicator> indicators,
      {String? key, int? index}) {
    if (null != key && !indicators.contains(key)) {
      return '';
    }
    index ??= indexOf(indicators, key!);
    StringIndicator? next = nextAvailable(indicators, index);
    return prompt.substring(index < 0 ? 0 : indicators[index].end + 1,
        next != null ? next.start - 2 : null);
  }

  static int indexOf(List<StringIndicator> indicators, String key) {
    for (int i = 0; i < indicators.length; i++) {
      if (key == indicators[i].key) return i;
    }
    return -1;
  }

// Pair a = findPrompt(0, prompt, NEGATIVE_KEY);
// result.prompt=a.a;
// Pair
// Pair findPrompt(int start,String prompt,String key){
//   return Pair(prompt,key);
// }
}
