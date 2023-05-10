import 'package:flutter/foundation.dart';
import '../../../bean/enum/set_type.dart';
import 'NetWorkStateProvider.dart';



class TXT2IMGModel with ChangeNotifier, DiagnosticableTreeMixin {

  SetType setIndex = SetType.basic;


  double? progress = 0;
  Uint8List? previewData;

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
