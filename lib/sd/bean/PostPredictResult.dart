import 'Data.dart';

class RunPredictResult {
  RunPredictResult({
      required this.data,
      required this.isGenerating,
      required this.duration,
      required this.averageDuration,});

  RunPredictResult.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(Data.fromJson(v));
      });
    }
    isGenerating = json['is_generating'];
    duration = json['duration'];
    averageDuration = json['average_duration'];
  }
  List<Data> data = [];
  bool isGenerating = false;
  double duration = 0;
  double averageDuration = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    // if (data != null) {
    //   map['data'] = data.map((v) => v.toJson()).toList();
    // }
    map['is_generating'] = isGenerating;
    map['duration'] = duration;
    map['average_duration'] = averageDuration;
    return map;
  }

}