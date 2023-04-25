
import 'Named.dart';
import 'Option.dart';

class Sampler implements Named {
  Sampler(this.name,{
      this.aliases,
      this.options,});

  Sampler.fromJson(dynamic json) {
    name = json['name'];
    // aliases = json['aliases'] != null ? json['aliases'].cast<String>() : [];
    // options = Option.fromJson(json['options']);
  }
  String name = "";
  List<String>? aliases;
  Option? options;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['aliases'] = aliases;
    map['options'] = options;
    return map;
  }

  @override
  String getInterfaceName() {
    return name;
  }

}