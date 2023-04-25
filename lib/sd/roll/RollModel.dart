import 'package:flutter/foundation.dart';
import 'package:sd/sd/roll/roll_widget.dart';

class RollModel with ChangeNotifier, DiagnosticableTreeMixin {
  SetType setIndex = SetType.basic;

  int isGenerating = 0; //-1 表示上次执行报错 点击历史查看 0表示刚初始化/请求成功 1 表示正在请求

  double? progress = 0;
  Uint8List? previewData;

  void isBusy(int i) {
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
