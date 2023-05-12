import 'package:flutter/foundation.dart';

import '../../bean/PromptStyle.dart';
import '../../bean/enum/CreateStyleType.dart';
import '../../bean/enum/StorageType.dart';

class CreateStyleModel with ChangeNotifier, DiagnosticableTreeMixin {
  static const TAG = "CreateStyleModel";

  String newFileName = "";

  StorageType? storageType = StorageType.Public;
  CreateStyleType? resType = CreateStyleType.empty;

  String splitFile = "";
  List<PromptStyle> current = [];

  String getCheckStyles() {
    String result = "";
    for (PromptStyle item in current) {
      if (null!=item.checked&&item.checked!) {
        result += "${item.name}\r\n";
      }
    }
    return result;
  }

  void updateStorageType(StorageType storageType) {
    this.storageType = storageType;
    notifyListeners();
  }

  void updateCreateStyleType(CreateStyleType? value) {
    this.resType = value;
    notifyListeners();
  }

  void upDateCurrent(String name,List<PromptStyle> list) {
    splitFile = name;
    current = list;
    notifyListeners();
  }

  void updateCheckState(int index, bool value) {
    current[index].checked = value;
    notifyListeners();
  }

  List<PromptStyle> copy(List<PromptStyle> split) {
    List<PromptStyle> result = [];
    for (PromptStyle style in split) {
      result.add(PromptStyle(
          style.name,
          // type: style.type,
          prompt: style.prompt,
          negativePrompt: style.negativePrompt));
    }
    return result;
  }

  void updateFileName(String text) {
    newFileName = text;
    notifyListeners();
  }
}
