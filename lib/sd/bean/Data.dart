class Data {
  Data({
      this.choices, 
      this.value, 
      this.type,});

  Data.fromJson(dynamic json) {
    choices = json['choices'] != null ? json['choices'].cast<String>() : [];
    value = json['value'];
    type = json['__type__'];
  }
  List<String>? choices;
  String? value;
  String? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['choices'] = choices;
    map['value'] = value;
    map['__type__'] = type;
    return map;
  }

}