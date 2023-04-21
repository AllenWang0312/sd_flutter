// const PROMPT_KEY = 'Prompt:';
import 'dart:convert';

import '../../common/bean/StringIndicator.dart';
import '../config.dart';
import '../http_service.dart';
import '../const/SDConst.dart';

class Configs {
  static const String TAG = "Prompt";

  String prompt = '';
  String negativePrompt = '';
  int steps = DEFAULT_SAMPLER_STEPS;
  String sampler = DEFAULT_SAMPLER;
  double cfgScale = 7.0;
  int seed = -1;
  String modelHash = '';
  String _size = '512x768';

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

  static Configs fromString(String prompt) {
    String json = '{Prompt:$prompt}';
    JsonDecoder decoder = JsonDecoder();
    dynamic config = decoder.convert(json);
    logt(TAG,config["Prompt"]);


    List<StringIndicator> indicators = KEYS.map((e) {
      int start = prompt.indexOf(e);
      int end = start + e.length;
      return StringIndicator(e, start, end);
    }).toList()
      ..sort((a, b) => a.start - b.start);
    logt(TAG, indicators.toString());

    Configs result = Configs();
    result.prompt = substring(prompt, indicators, -1);
    result.negativePrompt =
        getPrompt(prompt, indicators, indicators.indexOf(NEGATIVE_KEY as StringIndicator));

    if (indicators[1].start == -1) {
      result.steps = int.parse(substring(prompt, indicators, 1));
    }
    if (indicators[2].start == -1) {
      result.sampler = substring(prompt, indicators, 2);
    }
    if (indicators[3].start == -1) {
      result.cfgScale = double.parse(substring(prompt, indicators, 3));
    }
    if (indicators[4].start == -1) {
      result.seed = int.parse(substring(prompt, indicators, 4));
    }
    if (indicators[5].start == -1) {
      result.modelHash = substring(prompt, indicators, 5);
    }
    // result.modelHash = prompt.substring(
    //     indicators[5].end + 1, nextAvailable(indicators, 5)?.start - 2);
    // result.size = prompt.substring(indicators[6].end + 1);
    return result;
  }

  static String substring(
      String prompt, List<StringIndicator> indicators, int i) {
    StringIndicator? next = nextAvailable(indicators, i);
    return prompt.substring(
        i < 0 ? 0 : indicators[i].end, next != null ? next.start - 2 : null);
  }

  static String getPrompt(
      String prompt, List<StringIndicator> indicators, int index) {
    if (indicators[index].start != -1) {
      return substring(prompt, indicators, index);
    }
    return '';
  }

// Pair a = findPrompt(0, prompt, NEGATIVE_KEY);
// result.prompt=a.a;
// Pair
// Pair findPrompt(int start,String prompt,String key){
//   return Pair(prompt,key);
// }
}
