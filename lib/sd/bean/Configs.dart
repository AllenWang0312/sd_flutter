// const PROMPT_KEY = 'Prompt:';
import 'package:sd/common/bean/StringIndicator.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/const/SDConst.dart';
import 'package:sd/sd/const/default.dart';
import 'package:sd/sd/http_service.dart';

Configs pauseConfigs(String allPrompts) {
  List<StringIndicator> indicators = KEYS
      .map((e) {
        int start = allPrompts.indexOf(e);
        int end = start + e.length;
        return StringIndicator(e, start, end);
      })
      .where((element) => element.start > 0)
      .toList()
    ..sort((a, b) => a.start - b.start);
  logt(TAG, indicators.toString());

  Configs result = Configs();
  result.prompt = withDefault(substring(allPrompts, indicators, index: -1), '');
  result.negativePrompt =
      withDefault(substring(allPrompts, indicators, key: NEGATIVE_KEY), '');
  result.steps = toInt(substring(allPrompts, indicators, key: STEPS_KEY), 30);
  result.sampler =
      withDefault(substring(allPrompts, indicators, key: SAMPLER_KEY), '');
  result.cfgScale =
      toDouble(substring(allPrompts, indicators, key: CFG_KEY), 7.0);
  result.seed = toInt(substring(allPrompts, indicators, key: SEED_KEY), -1);
  result.modelHash =
      withDefault(substring(allPrompts, indicators, key: MODEL_HASH_KEY), '');

  result.model =
      withDefault(substring(allPrompts, indicators, key: MODEL_KEY), '');
  result._seedResizeFrom = withDefault(
      substring(allPrompts, indicators, key: SEED_RESIZE_FROM_KEY), '-1x-1');
  result.modelHash =
      withDefault(substring(allPrompts, indicators, key: MODEL_HASH_KEY), '');
  result.size =
      withDefault(substring(allPrompts, indicators, key: SIZE_KEY), '768x512');
  ;
  logt(TAG, result.toString());
  return result;
}

String substring(String prompt, List<StringIndicator> indicators,
    {String? key, int? index}) {
  if (null != key && !indicators.contains(key)) {
    return '';
  }
  index ??= indexOf(indicators, key!);
  StringIndicator? next = nextAvailable(indicators, index);
  return prompt.substring(index < 0 ? 0 : indicators[index].end + 1,
      next != null ? next.start - 2 : null);
}

int indexOf(List<StringIndicator> indicators, String key) {
  for (int i = 0; i < indicators.length; i++) {
    if (key == indicators[i].key) return i;
  }
  return -1;
}

StringIndicator? nextAvailable(List<StringIndicator> indicators, int index) {
  for (int i = index + 1; i < indicators.length; i++) {
    if (indicators[i].start != -1) {
      return indicators[i];
    }
  }
  return null;
}

class Configs {
  static const String TAG = "Prompt";

  String prompt = '';
  String negativePrompt = '';

  int steps = DEFAULT_SAMPLER_STEPS;
  int shapSteps = DEFAULT_SAMPLER_STEPS;
  int detailSteps = DEFAULT_SAMPLER_STEPS;


  double bgWeight = 2.0; //环境比重 比重0-5  图片长变>短边*1.5时生效

  double weight = 6.0; //主体/装饰物 比重0-10

  String sampler = DEFAULT_SAMPLER;
  double cfgScale = 7.0;
  int seed = -1;
  String modelHash = '';
  String model = '';

  String _size = '512x768';
  String _seedResizeFrom = '-1x-1';
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
        '$STEPS_KEY $steps, $SAMPLER_KEY $sampler, $CFG_KEY $cfgScale, $SEED_KEY $seed,$MODEL_KEY $model, $MODEL_HASH_KEY $modelHash, $SIZE_KEY ${_size ?? '$width x$height'} $SEED_RESIZE_FROM_KEY $_seedResizeFrom';
  }

// Pair a = findPrompt(0, prompt, NEGATIVE_KEY);
// result.prompt=a.a;
// Pair
// Pair findPrompt(int start,String prompt,String key){
//   return Pair(prompt,key);
// }
}
