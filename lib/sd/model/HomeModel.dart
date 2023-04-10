import 'package:flutter/foundation.dart';
import 'package:sd/sd/fragment/roll_widget.dart';

class HomeModel with ChangeNotifier, DiagnosticableTreeMixin {
  int index = 0;

  void updateIndex(int index) {
    this.index = index;
    notifyListeners();
  }
}
