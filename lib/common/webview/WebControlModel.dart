
import 'package:flutter/cupertino.dart';

class WebControlModel with ChangeNotifier {
  String? url;
  double? progress;

  void updateCurrentUrl(String? currentUrl) {
    this.url = currentUrl;
    notifyListeners();
  }

  void updateProgress(double? progress) {
    this.progress = progress;
    notifyListeners();
  }
}
