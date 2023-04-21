import 'dart:ui';

import 'package:flutter/foundation.dart';

class HomeModel with ChangeNotifier, DiagnosticableTreeMixin {
  int index = 0;

  void updateIndex(int index) {
    this.index = index;
    notifyListeners();
  }
}
