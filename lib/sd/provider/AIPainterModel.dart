import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/UserInfo.dart';
import 'package:sd/sd/provider/config_model.dart';
import 'package:sd/sd/roll/tagger_widget.dart';
import 'package:sd/sd/tavern/bean/ImageSize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../common/splash_page.dart';
import '../bean/Configs.dart';
import '../bean/PromptStyle.dart';
import '../bean/db/PromptStyleFileConfig.dart';
import '../bean/db/Workspace.dart';
import '../bean4json/UpScaler.dart';
import '../const/config.dart';
import '../db_controler.dart';
import '../http_service.dart';
import 'index_recorder.dart';

//存放需要在闪屏页初始化的配置

class AIPainterModel extends ConfigModel with IndexRecorder{
  static const String TAG = 'AIPainterModel';
  int countdownNum = SPLASH_WATTING_TIME; // todo 连同timer 封装到组件  闪屏页倒计时

  // UserInfo? userInfo = null;
  bool sdServiceAvailable = false;
  String? selectedSDModel = "";
  String selectedInterrogator = DEFAULT_INTERROGATOR;
  List<UpScaler> upScalers = [];

  String lastGenerate = '';



  // late Map<String, ImageSize?> imgSize = {};
  // bool https = false;
  // double denoisingStrength = 0.3;
  // int resizeWidth = 0;
  // int resizeHeight = 0;
  // String selectedSDModel = "";
  // Map<String, double> checkedPlugins = Map(); // lora


  @override
  void updateIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  void switchCheckState(String prefix, String name) {
    if (checkedPlugins.keys.contains("$prefix:$name")) {
      checkedPlugins.remove("$prefix:$name");
      // prompt.replaceAll(getPluginMarch(prefix, name), "");
    } else {
      checkedPlugins.putIfAbsent('$prefix:$name', () => 1.0);
      // prompt+="<$prefix:$name:1.0>";
    }
    notifyListeners();
  }


  updateSDModel(String? model) {
    selectedSDModel = model;
    logt(TAG, model??"null");
    notifyListeners();
  }

  // refreshStyles(List<String> choices) {
  //   checkedStyles.forEach((element) {
  //     if (!choices.contains(element)) {
  //       checkedStyles.remove(element);
  //     }
  //   });
  //   notifyListeners();
  // }

  countDown() {
    countdownNum--;
    notifyListeners();
  }

  void selectInterrogator(newValue) {
    selectedInterrogator = newValue;
    notifyListeners();
  }



  String getCheckedPluginsString() {
    String result = "";
    for (String key in checkedPlugins.keys) {
      result += "<$key:${checkedPlugins[key]}>";
    }
    return result;
  }



  int limitedUrl(String imgUrl) {
    return limit[imgUrl] ?? 0;
  }


  // void updateLastGenerate(String lastGenerate){
  //   this.lastGenerate = lastGenerate;
  //
  //   notifyListeners();
  // }


}
