import 'dart:math';

import 'package:sd/common/splash_page.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/bean4json/UpScaler.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/pages/home/txt2img/tagger_widget.dart';
import 'package:sd/sd/provider/config_model.dart';
import 'package:sd/sd/provider/index_recorder.dart';

//存放需要在闪屏页初始化的配置
//todo 类瘦身 没必要常态化持有的 拆分出去

const String TAG = 'AIPainterModel';

class AIPainterModel extends ConfigModel
    with IndexRecorder, NetWorkStateProvider {
  int countdownNum = SPLASH_WATTING_TIME; // todo 连同timer 封装到组件  闪屏页倒计时

  String? selectedSDModel;

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

  bool currentModelSupport(String? wlist) {
    if (wlist == null || wlist.isEmpty) return true;
    var wlis = wlist.split(",");
    for (var item in wlis) {
      if (selectedSDModel?.contains(item) == true) {
        return true;
      }
    }
    return false;
  }

  void setAgeLevel(String sign, int value) {
    if (value > 0) {
      limit.putIfAbsent(sign, () => value);
    } else {
      limit.remove(sign);
    }
    notifyListeners();
  }

  int getAgeLevel(String sign) {
    return limit[sign] ?? 0;
  }

  @override
  void updateIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  @override
  void updateNetworkState(int i) {
    netWorkState = i;
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
    logt(TAG, model ?? "null");
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

  void randomCheckedStyle() {
    optional.refreshCheck(this,random:true);
    notifyListeners();
  }

  void unCheckRadio(String name, String? bList) {
    int index = checkedRadio.indexOf(name);
    if (index >= 0) {
      checkedRadio.remove(name);
      if (null != bList) unRegBList(toList(bList));
      checkedRadioGroup.removeAt(index);
      notifyListeners();
    }
  }

  void removeCheckedStyles(String item, {String? bList, bool refresh = false}) {
    checkedStyles.remove(item);
    if (null != bList) unRegBList(toList(bList));
    if (refresh) {
      notifyListeners();
    }
  }

  void addCheckedStyles(String other, {String? bList, bool refresh = false}) {
    checkedStyles.add(other);
    if (null != bList) regBList(toList(bList));
    if (refresh) {
      notifyListeners();
    }
  }

  void updateBgWeight(double value) {
    txt2img.bgWeight = value;
    notifyListeners();
  }

  void updateWeight(double value) {
    txt2img.weight = value;
    notifyListeners();
  }

  int selectedStyleLen() {
    return checkedRadio.length + checkedStyles.length;
  }

  void updateAutoGenerate(bool value) {
    autoGenerate = value;
    notifyListeners();
  }

  //2560 1440 1280 720
  //3840*2160 1/2 1920*1080 1/3 1280*720 雷鸟s515c
  //2688*1242 1/2 1344*621 iphone xs max
  //2400x1080 1/2 1200*540 一加8
  // 800 480 小米桌面音响
  // 768 512 默认
  static const sizes = [
    [768, 512],
    [800, 480],
    [1200, 540],
    [1280, 720],
    [1344, 621],
  ];

  void randomSizeIfNeed() {
    if (!hwLocked) {
      int vertical;
      if (hwSwitchLock) {
        vertical = isVertical ? 1 : 0;
      } else {
        vertical = Random().nextInt(2); //0 横 1 竖 2 等边
        hwSwitchLock = vertical == 1;
      }

      int size = Random().nextInt(4);
      if (vertical == 2) {
        txt2img.width = 768;
        txt2img.height = 768;
      } else if (vertical == 1) {
        txt2img.width = sizes[size][1];
        txt2img.height = sizes[size][0];
      } else if (vertical == 0) {
        txt2img.width = sizes[size][0];
        txt2img.height = sizes[size][1];
      }
      isVertical = txt2img.height > txt2img.width;
      notifyListeners();
    }
  }

  void updateVibrate(bool value) {
    vibrate = value;
    notifyListeners();
  }

  // void updateLastGenerate(String lastGenerate){
  //   this.lastGenerate = lastGenerate;
  //
  //   notifyListeners();
  // }

  void switchWH() {
    int width = txt2img.width;
    txt2img.width = txt2img.height;
    txt2img.height = width;
    isVertical = txt2img.height > txt2img.width;
    notifyListeners();
  }

  void updateHWLocked(bool value) {
    this.hwLocked = value;
    notifyListeners();
  }

  void updateHWSwitchLocked(bool value) {
    this.hwSwitchLock = value;
    notifyListeners();
  }

  bool inBList(String group) {
    return null != blistCount[group] && blistCount[group]! > 0;
  }
}
