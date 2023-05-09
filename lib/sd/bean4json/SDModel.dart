
import 'Named.dart';

class SdModel implements Named {
  SdModel({
    required this.title,
    required this.modelName,
    required this.filename,

    this.hash,
    this.sha256,
    this.config,
  });

  SdModel.fromJson(dynamic json) {
    title = json['title'];
    modelName = json['model_name'];
    hash = json['hash'];
    sha256 = json['sha256'];
    filename = json['filename'];
    config = json['config'];
  }
  SdModel.fromString(String fileName) {
    this.filename = fileName;
  }

  late String title;
  late String filename;
  late String modelName;
  String? hash;
  String? sha256;
  dynamic? config;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['model_name'] = modelName;
    map['hash'] = hash;
    map['sha256'] = sha256;
    map['filename'] = filename;
    map['config'] = config;
    return map;
  }

  @override
  String getInterfaceName() {
    return title;
  }

  @override
  String toString() {
    return title;
  }
}
