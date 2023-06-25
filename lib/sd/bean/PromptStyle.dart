import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/http_service.dart';

const TAG = "PromptStyle";

class PromptStyle {

  static var GROUP = 'group';
  static var STEP = 'step'; //0镜头 1 场景环境 2女主体 特征  3女主体整体(动作关系等) 4女主体细节  5环境道具 6男主体特征 [7 8] 9多主体之间关系

  static var TYPES = ['词组', 'n', 'adj.', 'v', '副词.'];

  static var TYPE = 'type'; //1 名词 2 形容词(包括颜色) 3动词 4 副词 21 形容词+名词
  static var NAME = 'name';
  static var LIMIT_AGE = 'limit_age';
  static var PROMPT = 'prompt';
  static var NEG_PROMPT = 'negative_prompt';
  static var WEIGHT = 'weight';

  static String TABLE_NAME = "prompt_styles";
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY,group TEXT, name TEXT,step INTEGER,limitAge INTEGER,prompt TEXT,negativePrompt TEXT";

  String? _readableType;

  String? get readableType {
    if (_readableType == null) {
      _readableType = '';
      if (type != null && type!.isNotEmpty) {
        List types = type!.split('');
        for (String i in types) {
          _readableType = '${_readableType!}${TYPES[toInt(i, 0)]} ';
        }
      }
    }
    return _readableType;
  }

  int? limitAge = 0;

  String group = '';
  int step = -1;
  String? type = '';
  String name = "";
  String? prompt = "";
  String? negativePrompt = "";

  int weight = 1;


  int promptLen = 0;
  int negativeLen = 0;

  PromptStyle(
    this.name, {
    this.group = '',
    this.step = 0,
    this.type,
    this.limitAge,
    this.prompt,
    this.negativePrompt,
        this.weight = 1,
  }) {
    promptLen = wordsCount(prompt);
    negativeLen = wordsCount(negativePrompt);
    // logt(TAG,"prompt $promptLen negative $negativeLen");
  }

  bool? checked;

  PromptStyle.fromJson(dynamic json) {
    group = json['group'];
    name = json['name'];
    limitAge = toInt(json['limit_age'], 0);
    step = toInt(json['step'], 0);
    type = json['type'];
    prompt = json['prompt'];
    negativePrompt = json['negative_prompt'];
    weight = json['weight'];
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
    map['type'] = type;
    map['prompt'] = prompt;
    map['negative_prompt'] = negativePrompt;
    map['weight'] = weight;
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

  static List STYLE_HEAD = [
    GROUP,
    NAME,
    STEP,
    TYPE,
    LIMIT_AGE,
    PROMPT,
    NEG_PROMPT
  ];

  static List<dynamic> convertItem(dynamic item) {
    return [
      item['group'],
      item['name'],
      item['step'],
      item['type'],
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
      item.type,
      item.step,
      item.prompt,
      item.negativePrompt,
    ];
  }

  @override
  String toString() {
    return 'group: $group, step: $step, limitAge: $limitAge, promptLen: $promptLen, negativeLen: $negativeLen, checked: $checked, name: $name, prompt: $prompt, negativePrompt: $negativePrompt';
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
