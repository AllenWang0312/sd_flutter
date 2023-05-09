import 'package:flutter/foundation.dart';
import 'package:sd/sd/roll/roll_widget.dart';

import 'NetWorkStateProvider.dart';



class RollModel with ChangeNotifier, DiagnosticableTreeMixin, NetWorkStateProvider {
  SetType setIndex = SetType.basic;


  double? progress = 0;
  Uint8List? previewData;
  bool backgroundProgress = true; //后台10s 检查progress 或者请求时 主动1s检查 progress

  @override
  void updateNetworkState(int i) {
    isGenerating = i;
    notifyListeners();
  }

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
