import 'package:flutter/foundation.dart';

import '../bean/db/PromptStyleFileConfig.dart';
import '../bean/enum/StorageType.dart';
import '../bean/enum/StyleResType.dart';
import '../http_service.dart';

const TAG = "CreateWSModel";

bool existConfig(List<PromptStyleFileConfig> all, String path) {
  for (PromptStyleFileConfig item in all) {
    if (item.configPath == path) {
      logt(TAG, "exist config");
      return item.state == 1;
    }
  }
  return false;
}

bool needAddConfig(List<PromptStyleFileConfig> all, String path) {
  for (PromptStyleFileConfig item in all) {
    if (item.configPath == path) {
      logt(TAG, "need add config");
      return item.state == 2;
    }
  }
  return false;
}

class CreateWSModel with ChangeNotifier, DiagnosticableTreeMixin {
  StorageType? storageType = StorageType.Private;
  StyleResType? styleResType = StyleResType.reomote;
  String styleConfigPath = "";

  List<PromptStyleFileConfig> allConfig = [];

  bool noMediaFileExist = false;


  void updateStorageType(StorageType storageType) {
    this.storageType = storageType;
    notifyListeners();
  }

  void updateStyleResType(StyleResType? value, String path) {
    this.styleConfigPath = path;
    this.styleResType = value!;
    notifyListeners();
  }

  void updateConfig(int index, bool value) {
    var item = allConfig[index];
    updateItem(item, value);
    logt(
        TAG,
        "all config update" +
            item.state.toString() +
            value.toString());
    notifyListeners();
  }

  void updateItem(PromptStyleFileConfig item, bool value) {
    if (value) {
      if (item.state == -1) {
        item.state = 1;
      } else if (item.state == 0) {
        item.state = 2;
      }
    } else {
      if (item.state == 2) {
        item.state = 0;
      } else if (item.state == 1) {
        item.state = -1;
      }
    }
  }
}
