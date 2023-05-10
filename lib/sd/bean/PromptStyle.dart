import 'package:sd/common/util/string_util.dart';

class PromptStyle {
  static var GROUP = 'group';
  static var STEP = 'step';
  static var NAME = 'name';
  static var LIMIT_AGE = 'limit_age';

  static var PROMPT = 'prompt';
  static var NEG_PROMPT = 'negative_prompt';

  static List STYLE_HEAD = [
    'group',
    'step',
    'name',
    'limit_age',
    'prompt',
    'negative_prompt'
  ];

  static String TABLE_NAME = "prompt_styles";
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY,group TEXT, name TEXT,step INTEGER,limitAge INTEGER,prompt TEXT,negativePrompt TEXT";

  String? group = '';
  int? step = 0;
  int? limitAge = 0;

  String name = "";
  String? prompt = "";
  String? negativePrompt = "";

  int promptLen = 0;
  int negativeLen = 0;

  PromptStyle(
    this.name, {
    this.group = "",
    this.step = 0,
    this.limitAge = 0,
    this.prompt,
    this.negativePrompt,
  }) {
    promptLen = wordsCount(prompt);
    negativeLen = wordsCount(negativePrompt);
    // logt(TAG,"prompt $promptLen negative $negativeLen");
  }

  bool checked = false;

  PromptStyle.fromJson(dynamic json) {
    group = json['group'];
    name = json['name'];
    limitAge = toInt(json['limit_age'],0);
    step = toInt(json['step'], 0);
    prompt = json['prompt'];
    negativePrompt = json['negative_prompt'];
  }

  bool get isEmpty {
    return (prompt == null || prompt!.isEmpty) &&
        (negativePrompt == null || negativePrompt!.isEmpty);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['group'] = group;

    map['name'] = name;
    map['limit_age'] = limitAge;
    map['step'] = step;
    map['prompt'] = prompt;
    map['negative_prompt'] = negativePrompt;
    return map;
  }

  static List<List<dynamic>>? convertDynamic(List re) {
    List<List<dynamic>>? result = re.map((e) {
      return convertItem(e);
    }).toList();
    result.insert(0, STYLE_HEAD);
    return result;
  }

  static List<List<dynamic>>? convertPromptStyle(List<PromptStyle> re) {
    List<List<dynamic>>? result = re.map((e) {
      return convertBean(e);
    }).toList();
    result.insert(0, STYLE_HEAD);
    return result;
  }

  static List<dynamic> convertItem(dynamic item) {
    return [
      item['group'],
      item['name'],
      item['step'],
      item['limit_age'],
      item['prompt'],
      item['negative_prompt'],
    ];
  }

  static List<dynamic> convertBean(PromptStyle item) {
    return [
      item.group,
      item.name,
      item.limitAge,
      item.step,
      item.prompt,
      item.negativePrompt,
    ];
  }

  @override
  String toString() {
    return 'PromptStyle{group: $group, step: $step, limitAge: $limitAge, promptLen: $promptLen, negativeLen: $negativeLen, checked: $checked, name: $name, prompt: $prompt, negativePrompt: $negativePrompt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptStyle &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          limitAge == other.limitAge &&
          prompt == other.prompt &&
          negativePrompt == other.negativePrompt;

  @override
  int get hashCode => name.hashCode ^ prompt.hashCode ^ negativePrompt.hashCode;

  int wordsCount(String? prompt) {
    return null == prompt || prompt.isEmpty
        ? 0
        : (prompt.contains('.') ? prompt.split('.').length : 1);
  }
}
