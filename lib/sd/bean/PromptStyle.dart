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

  PromptStyle.fromJson(dynamic json) {
    name = json['name'];
    type = json['type'];
    prompt = json['prompt'];
    negativePrompt = json['negative_prompt'];
  }

  String name = "";
  String? type;
  String prompt = "";
  String negativePrompt = "";

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['type'] = type;
    map['prompt'] = prompt;
    map['negative_prompt'] = negativePrompt;
    return map;
  }

  static List csvHead = ['name', 'type', 'prompt', 'negative_prompt'];

  static List<List?>? convert(List re) {
    List<List?>? result =re
        .map((e) => [e['name'], e['type'], e['prompt'], e['negative_prompt']])
        .toList();
       result.insert(0, csvHead);
    return result;
  }
}
