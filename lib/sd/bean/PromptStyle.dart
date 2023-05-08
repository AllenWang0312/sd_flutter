import '../http_service.dart';

class PromptStyle {
  static String TABLE_NAME = "prompt_styles";
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY, name TEXT,prompt TEXT,negativePrompt TEXT";

  // static var NAME = 'name';
  // static var TYPE = 'type';
  // static var PROMPT = 'prompt';
  // static var NEG_PROMPT = 'negative_prompt';

  int flag = 0;

  int promptLen = 0;
  int negativeLen = 0;

  PromptStyle(
      this.name,
      {
    // this.type,
    this.prompt,
    this.negativePrompt,
        this.flag = 0
  }){
    promptLen = wordsCount(prompt);
    negativeLen = wordsCount(negativePrompt);
    // logt(TAG,"prompt $promptLen negative $negativeLen");
  }

  bool checked = false;

  PromptStyle.fromJson(dynamic json) {
    name = json['name'];
    // type = json['type'];
    prompt = json['prompt'];
    negativePrompt = json['negative_prompt'];
  }

  String name = "";
  // String? type;
  String? prompt = "";
  String? negativePrompt = "";

  bool get isEmpty{
    return (prompt==null||prompt!.isEmpty)&&(negativePrompt==null||negativePrompt!.isEmpty);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    // map['type'] = type;
    map['prompt'] = prompt;
    map['negative_prompt'] = negativePrompt;
    return map;
  }

  static List csvHead = ['name', 'type', 'prompt', 'negative_prompt'];

  static List<List<dynamic>>? convertDynamic(List re) {
    List<List<dynamic>>? result = re.map((e) {
      return convertItem(e);
    }).toList();
    result.insert(0, csvHead);
    return result;
  }
  static List<List<dynamic>>? convertPromptStyle(List<PromptStyle> re) {
    List<List<dynamic>>? result = re.map((e) {
      return convertBean(e);
    }).toList();
    result.insert(0, csvHead);
    return result;
  }

  static List<dynamic> convertItem(dynamic item) {
    return [
      item['name'],
      // item['type'],
      item['prompt'],
      item['negative_prompt'],
    ];
  }

  static List<dynamic> convertBean(PromptStyle item) {
    return [
      item.name,
      // item.type,
      item.prompt,
      item.negativePrompt,
    ];
  }

  @override
  String toString() {
    return 'PromptStyle{checked: $checked, name: $name, prompt: $prompt, negativePrompt: $negativePrompt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptStyle &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          // type == other.type &&
          prompt == other.prompt &&
          negativePrompt == other.negativePrompt;

  @override
  int get hashCode =>
      name.hashCode ^ prompt.hashCode ^ negativePrompt.hashCode;

  int wordsCount(String? prompt) {
   return null==prompt||prompt.isEmpty?0:(prompt.contains('.')?prompt.split('.').length:1);
  }
}
