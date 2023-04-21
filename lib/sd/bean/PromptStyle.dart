class PromptStyle {
  static String TABLE_NAME = "prompt_styles";
  static String TABLE_CREATE =
      "id INTEGER PRIMARY KEY, name TEXT,type TEXT,prompt TEXT,negativePrompt TEXT";

  static var NAME = 'name';
  static var TYPE = 'type';
  static var PROMPT = 'prompt';
  static var NEG_PROMPT = 'negative_prompt';

  PromptStyle({
    required this.name,
    this.type,
    required this.prompt,
    required this.negativePrompt,
  });

  bool checked = false;

  PromptStyle.fromJson(dynamic json) {
    name = json['name'];
    type = json['type'];
    prompt = json['prompt'];
    negativePrompt = json['negative_prompt'];
  }

  String name = "";
  String? type;
  String? prompt = "";
  String? negativePrompt = "";

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['type'] = type;
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
      item['type'],
      item['prompt'],
      item['negative_prompt'],
    ];
  }

  static List<dynamic> convertBean(PromptStyle item) {
    return [
      item.name,
      item.type,
      item.prompt,
      item.negativePrompt,
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptStyle &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          prompt == other.prompt &&
          negativePrompt == other.negativePrompt;

  @override
  int get hashCode =>
      name.hashCode ^ type.hashCode ^ prompt.hashCode ^ negativePrompt.hashCode;
}
