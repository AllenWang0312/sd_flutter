import 'package:sd/sd/bean/Named.dart';

class UpScaler implements Named {

  UpScaler({
      required this.name,
      this.modelName, 
      this.modelPath, 
      this.modelUrl, 
      required this.scale,});

  UpScaler.fromJson(dynamic json) {
    name = json['name'];
    modelName = json['model_name'];
    modelPath = json['model_path'];
    modelUrl = json['model_url'];
    scale = json['scale'];
  }
  String name = "";
  String? modelName;
  String? modelPath;
  String? modelUrl;
  double scale = 4.0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['model_name'] = modelName;
    map['model_path'] = modelPath;
    map['model_url'] = modelUrl;
    map['scale'] = scale;
    return map;
  }

  @override
  String getInterfaceName() {
   return name;
  }

}