
import 'package:flutter/foundation.dart';

import 'images_viewer.dart';

class ImagesModel with ChangeNotifier, DiagnosticableTreeMixin {
  String? currentRemoteFilePath;

  int index = 0;

  List<ExtInfo?> exts = [];

  void pageChanged(int index) {
    this.index = index;
    notifyListeners();
  }

  void updateCurrentDes(int index, String? des) {
    this.index = index;
    exts[index]?.prompts = des;
    notifyListeners();
  }

  void updateRemoteFilePath(int page, String data) {
    exts[page]?.remoteFilePath = data;
    notifyListeners();
  }

  void updateFavourete(int page, bool bool) {
    exts[page]?.favourite = bool;
    notifyListeners();
  }

  void removeExtsAt(int index) {
    exts.removeAt(index);
    if (this.index == index) {
      this.index--;
    }

    notifyListeners();
  }

  void updateIndex(int page) {
    index = page;
    notifyListeners();
  }

  void initExts(int size) {
    exts = [];
    for (int i = 0; i < size; i++) {
      exts.add(ExtInfo());
    }
    notifyListeners();
  }
}