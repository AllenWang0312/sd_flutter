//
// import 'Data.dart';
//
// class MultiGenerateResponse {
//   MultiGenerateResponse({
//       this.data,
//       this.isGenerating,
//       this.duration,
//       this.averageDuration,});
//
//   MultiGenerateResponse.fromJson(dynamic json) {
//     if (json['data'] != null) {
//       data = [];
//       json['data'].forEach((v) {
//         data.add(Data.fromJson(v));
//       });
//     }
//     isGenerating = json['is_generating'];
//     duration = json['duration'];
//     averageDuration = json['average_duration'];
//   }
//   List<List<Data>> data;
//   bool isGenerating;
//   double duration;
//   double averageDuration;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (data != null) {
//       map['data'] = data.map((v) => v.toJson()).toList();
//     }
//     map['is_generating'] = isGenerating;
//     map['duration'] = duration;
//     map['average_duration'] = averageDuration;
//     return map;
//   }
//
// }