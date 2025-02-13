import 'dart:collection';
import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/bean/Configs.dart';
import 'package:sd/sd/bean/Optional.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/const/default.dart';
import 'package:sd/sd/const/sp_key.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/provider/db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const TAG = "SPModel";

class SPModel extends DBModel {
//todo ui不依赖 可以 移走 单次请求接口方式 0 优先api 1 优先predict

  int generateType = 0; //公网 predict 会报错
  // String _cover =
  //     'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

  // String _cover = 'http://$sdHost:$SD_PORT/static/img/api-logo.svg';
  String? splashImg;
  Configs txt2img = Configs();

  bool faceFix = DEFAULT_FACE_FIX;
  bool hiresFix = false;

  int batchCount = 1;
  int batchSize = 1;

  // String host =
  bool autoGenerate = true;
  bool vibrate = false;

  bool hwLocked = true;
  bool hwSwitchLock = false;

  bool isVertical = true;

  bool autoSave = true;
  bool autoRandom = true;
  bool hideNSFW = true;
  bool checkIdentityWhenReEnter = true;

  double upscale = 2;

  int scalerWidth = DEFAULT_WIDTH;
  int scalerHeight = DEFAULT_HEIGHT;

  List<String>? require;
  //锁定的单选项group
  List<String> lockedRadioGroup = [];

  //选择的单选项group
  List<String> checkedRadioGroup = [];

  //选择的单选项
  List<String> checkedRadio = []; //

  //选择的多选项
  List<String> checkedStyles = [];

  //锁定的多选项
  List<String> lockedStyles = [];

  Map<String, int> blistCount = HashMap();
  Map<int, int> rangeValueIndex = HashMap(); //todo 记到本地缓存

  void updateRangeValue(int type, int newValue) {
    //
    if (rangeValueIndex.keys.contains(type)) {
      rangeValueIndex[type] = newValue;
    } else {
      rangeValueIndex.putIfAbsent(type, () => newValue);
    }
    notifyListeners();
  }

  void lockSelector(String name) {
    //锁定、取消锁定 某一项
    if (isSingle(name)) {
      //单选项
      if (checkedRadio.contains(name)) {
        //已选的包含
        String target = checkedRadioGroup[checkedRadio.indexOf(name)];
        if (lockedRadioGroup.contains(target)) {
          lockedRadioGroup.remove(target); //加入锁定
          logt(TAG, '$target unlocked $lockedRadioGroup $checkedRadioGroup');
        } else {
          lockedRadioGroup.add(target);
          logt(TAG, '$target locked $lockedRadioGroup $checkedRadioGroup');
        }
        notifyListeners();
      }
    } else {
      if (lockedStyles.contains(name)) {
        lockedStyles.remove(name);
        logt(TAG, '$name unlocked');
      } else {
        lockedStyles.add(name);
        logt(TAG, '$name locked');
      }
      notifyListeners();
    }
  }

  bool selectorLocked(String name) {
    int index = checkedRadio.indexOf(name);
    if (index >= 0) {
      String group = checkedRadioGroup[index];
      return lockedRadioGroup.contains(group);
    }
    return false;
  }

  void updateCheckRadio(String group, String? name, {String? require,String? bList}) {
    if (null != name) {
      bool exit = checkedRadioGroup.contains(group);
      if (exit) {
        checkedRadio[checkedRadioGroup.indexOf(group)] = name;
      } else {
        checkedRadioGroup.add(group);
        checkedRadio.add(name);
      }
      if (bList?.isNotEmpty==true) regBList(toList(bList!));
      this.require = require?.split(" ");
    } else {
      int index = checkedRadioGroup.indexOf(group);
      checkedRadio.removeAt(index);
      checkedRadioGroup.removeAt(index);
      if (bList?.isNotEmpty==true) unRegBList(toList(bList!));
      this.require = null;
    }
    logt(
        TAG,
        "${checkedRadioGroup.toString()}\n"
        " ${checkedRadio.toString()}");
    notifyListeners();
  }

  void regBList(List<String> blis, {bool refresh = false}) {
    blis.forEach((element) {
      if (blistCount.containsKey(element) != null) {
        blistCount.update(element, (value) => blistCount[element]! + 1);
      } else {
        blistCount.putIfAbsent(element, () => 1);
      }
    });
    if (refresh) notifyListeners();
  }

  List<String> toList(String bList) {
    if (bList.contains(",")) {
      return bList.split(",");
    } else {
      return [bList];
    }
  }

  void unRegBList(List<String> blis, {bool refresh = false}) {
    blis.forEach((element) {
      if (blistCount[element]! > 1) {
        blistCount.update(element, (value) => blistCount[element]! - 1);
      } else {
        blistCount.remove(element);
      }
    });
    if (refresh) notifyListeners();
  }

  void loadFromSP(SharedPreferences sp) {
    // share = sp.getBool(SP_SHARE)??false;
    // if(sdShare!){
    //   styleFrom = -1;
    // }else{
    styleFrom = sp.getInt(SP_PROMPT_TYPE) ?? 4;
    // }
    generateType = sp.getInt(SP_GENERATE_TYPE) ?? 0;

    // if (!UniversalPlatform.isIOS) {
    splashImg = '$sdHttpService/favicon.ico';
    // } else {
    //   splashImg = 'https://stability.ai/favicon.ico'; // ios 第一次https 调用才会触发授权弹框
    // }
    // splashImg = 'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

    txt2img.prompt = sp.getString(SP_PROMPT) ?? "";
    txt2img.negativePrompt = sp.getString(SP_NEG_PROMPT) ?? "";

    txt2img.sampler = sp.getString(SP_SAMPLER) ?? DEFAULT_SAMPLER;
    txt2img.steps = sp.getInt(SP_SAMPLER_STEPS) ?? DEFAULT_SAMPLER_STEPS;
    txt2img.width = sp.getInt(SP_WIDTH) ?? DEFAULT_WIDTH;
    txt2img.height = sp.getInt(SP_HEIGHT) ?? DEFAULT_HEIGHT;

    checkedStyles = sp.getStringList(SP_CHECKED_STYLES) ?? [];
    checkedRadioGroup = sp.getStringList(SP_CHECKED_RADIO_GROUPS) ?? [];
    lockedRadioGroup = sp.getStringList(SP_LOCKED_RADIO_GROUPS) ?? [];
    lockedStyles = sp.getStringList(SP_LOCKED_STYLES) ?? [];

    checkedRadio = sp.getStringList(SP_CHECKED_RADIOS) ?? [];

    faceFix = sp.getBool(SP_FACE_FIX) ?? DEFAULT_FACE_FIX;
    hiresFix = sp.getBool(SP_HIRES_FIX) ?? DEFAULT_HIRES_FIX;
    batchCount = sp.getInt(SP_BATCH_COUNT) ?? 1;
    batchSize = sp.getInt(SP_BATCH_SIZE) ?? 1;
    autoSave = sp.getBool(SP_AUTO_SAVE) ?? DEFAULT_AUTO_SAVE;
    hideNSFW = sp.getBool(SP_HIDE_NSFW) ?? DEFAULT_HIDE_NSFW;
    checkIdentityWhenReEnter =
        sp.getBool(SP_CHECK_IDENTITY) ?? DEFAULT_CHECK_IDENTITY;
  }

  savePromptsToSP({bool toast = false}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString(SP_PROMPT, txt2img.prompt);
    await sp.setString(SP_NEG_PROMPT, txt2img.negativePrompt);

    await sp.setString(SP_SAMPLER, txt2img.sampler);
    await sp.setInt(SP_SAMPLER_STEPS, txt2img.steps);
    await sp.setInt(SP_WIDTH, txt2img.width);
    await sp.setInt(SP_HEIGHT, txt2img.height);

    await sp.setStringList(SP_CHECKED_STYLES, checkedStyles);
    await sp.setStringList(SP_CHECKED_RADIOS, checkedRadio);
    await sp.setStringList(SP_CHECKED_RADIO_GROUPS, checkedRadioGroup);
    await sp.setStringList(SP_LOCKED_RADIO_GROUPS, lockedRadioGroup);
    await sp.setStringList(SP_LOCKED_STYLES, lockedStyles);

    await sp.setBool(SP_FACE_FIX, faceFix);
    await sp.setBool(SP_HIRES_FIX, hiresFix);
    await sp.setInt(SP_BATCH_COUNT, batchCount);
    await sp.setInt(SP_BATCH_SIZE, batchSize);
    if (toast) {
      Fluttertoast.showToast(msg: "保存成功");
    }
  }

  void updateGenerateType(int type) {
    this.generateType = type;
    notifyListeners();
  }

  void removePluginPrompt(String prefix, String name) {
    txt2img.prompt.replaceAll(
        getPluginMarch(prefix, name), ""); //todo replace 失效 导致重复append
  }

  void addPluginPrompt(String prefix, String name) {
    txt2img.prompt += "<$prefix:$name:1.0>";
  }

  void updatePrompt(String? prompt) {
    this.txt2img.prompt = prompt ?? "";
    notifyListeners();
  }

  void updatePrompts(String? prompt, String? negPrompt,
      {int? steps, String? sampler, double? cfgScale, double? seed}) {
    var newPrompts = autoCheckStyle(prompt ?? "", negPrompt ?? "");

    this.txt2img.prompt = newPrompts.prompt!;
    this.txt2img.negativePrompt = newPrompts.negativePrompt!;
    if (null != steps) this.txt2img.steps = min(100, steps);
    if (null != sampler) this.txt2img.sampler = sampler;
    if (null != cfgScale) this.txt2img.cfgScale = cfgScale;
    if (null != seed) this.txt2img.seed = seed.toInt();

    notifyListeners();
  }

  void updateConfigs(Configs prompt) {
    this.txt2img = prompt;
    notifyListeners();
  }

  void updateXValue(int value) {
    this.txt2img.XValue = value;
    notifyListeners();
  }

  void updateYValue(int value) {
    this.txt2img.YValue = value;
    notifyListeners();
  }

  void updateZValue(int value) {
    this.txt2img.ZValue = value;
    notifyListeners();
  }

  void updateNegPrompt(String negPrompt) {
    this.txt2img.negativePrompt = negPrompt;
    notifyListeners();
  }

  void updateBatch(double value) {
    batchCount = value.toInt();
    notifyListeners();
  }

  void updateBatchSize(double value) {
    batchSize = value.toInt();
    notifyListeners();
  }

  updateAutoSave(bool value) {
    autoSave = value;
    notifyListeners();
  }

  void setHiresFix(bool bool) {
    hiresFix = bool;
    notifyListeners();
  }

  void setFaceFix(bool bool) {
    faceFix = bool;
    notifyListeners();
  }

  void updateSteps(double value) {
    txt2img.steps = value.toInt();
    notifyListeners();
  }

  void updateShapeSteps(double value) {
    txt2img.shapSteps = value.toInt();
    notifyListeners();
  }

  void updateDetailSteps(double value) {
    txt2img.detailSteps = value.toInt();
    notifyListeners();
  }

  void selectSampler(String newValue) {
    txt2img.sampler = newValue;
    notifyListeners();
  }

  String? getCheckedRadio(String group) {
    if (checkedRadioGroup.contains(group)) {
      return checkedRadio[checkedRadioGroup.indexOf(group)];
    }
    return null;
  }

  // bool itemChecked(String? group, String name) {
  //   if(name.endsWith("*")&&null!=group){
  //     return checkedRadio[group] == name;
  //   }else{
  //     return checkedStyles.contains(name);
  //   }
  // }

  void switchChecked(bool checked, String name, String? bList) {
    if (checked
        //txt2img.checkedStyles.contains(name)
        ) {
      checkedStyles.add(name);
      if (bList?.isNotEmpty==true) regBList(toList(bList!));
    } else {
      checkedStyles.remove(name);
      if (bList?.isNotEmpty==true) unRegBList(toList(bList!));
    }
    notifyListeners();
  }

  void cleanCheckedStyles({bool notify = true}) {
    checkedStyles.clear();
    checkedRadioGroup.clear();
    checkedRadio.clear();
    notifyListeners();
  }

  // void replaceChecked(String? old, String? newValue) {
  //   if (txt2img.checkedStyles.contains(old)) {
  //     txt2img.checkedStyles.remove(old);
  //   }
  //   if (null != newValue) {
  //     switchChecked(newValue);
  //   }
  // }

  void updateWidth(double value) {
    txt2img.width = value.toInt();
    if (hiresFix) {
      scalerWidth = (upscale * txt2img.width).toInt();
    }
    notifyListeners();
  }

  void updateScale(double value) {
    upscale = value;
    scalerWidth = (txt2img.width * upscale).toInt();
    scalerHeight = (txt2img.height * upscale).toInt();
    notifyListeners();
  }

  void cleanPrompts() {
    txt2img = Configs();
    notifyListeners();
  }

  void updateHeight(double value) {
    txt2img.height = value.toInt();
    if (hiresFix) {
      scalerHeight = (upscale * txt2img.height).toInt();
    }
    notifyListeners();
  }

  unCheckStyles(String style, String? bList) {
    checkedStyles.remove(style);
    if (bList?.isNotEmpty==true) unRegBList(toList(bList!));

    checkedRadio.remove(styles);
    notifyListeners();
  }

  void updateHideNSFW(bool value) {
    hideNSFW = value;
    notifyListeners();
  }

  void updateCheckIdentity(bool value) {
    this.checkIdentityWhenReEnter = value;
    notifyListeners();
  }

  PromptStyle autoCheckStyle(String prompt, String negPrompt) {
    var result =
        PromptStyle('result', prompt: prompt, negativePrompt: negPrompt);

    for (PromptStyle style in styles) {
      if ((null == style.prompt ||
              style.prompt!.isEmpty ||
              prompt.contains("{${style.prompt}},")) &&
          (null == style.negativePrompt ||
              style.negativePrompt!.isEmpty ||
              negPrompt.contains("${style.negativePrompt},"))) {
        if (isSingle(style.name)) {
          updateCheckRadio(style.group, style.name, bList: style.bList);
        } else {
          checkedStyles.add(style.name);
          if (null != style.bList)
            regBList(toList(style.bList!), refresh: true);
        }
        result.prompt?.replaceAll("\{${style.prompt}\}\,", "");
        result.negativePrompt?.replaceAll("${style.negativePrompt}\,", "");

        logt(TAG,
            "after replace prompt:${style.prompt} neg: ${style.negativePrompt}");
        logt(TAG,
            "result prompt:${result.prompt} neg: ${result.negativePrompt} ");
      }
    }
    return result;
  }
}
