import 'package:flutter/foundation.dart';
import '../../../bean/enum/set_type.dart';

class IMG2IMGModel with ChangeNotifier, DiagnosticableTreeMixin {

  SetType setIndex = SetType.basic;


  double? progress = 0;
  Uint8List? previewData;
  bool backgroundProgress = true; //后台10s 检查progress 或者请求时 主动1s检查 progress


  void updateSetIndex(SetType value) {
    setIndex = value;
    notifyListeners();
  }

  void updateProgress(double? progress) {
    this.progress = progress;
    notifyListeners();
  }

  void updatePreviewData(Uint8List base64decode) {
    previewData = base64decode;
    notifyListeners();
  }



}
