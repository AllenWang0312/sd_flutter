import 'dart:math';

import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/bean/Configs.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/const/default.dart';
import 'package:sd/sd/const/sp_key.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/provider/db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

const TAG = "SPModel";

class SPModel extends DBModel {



//todo ui不依赖 可以 移走 单次请求接口方式 0 优先api 1 优先predict

  int generateType = 1;   // String _cover =
  //     'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

  // String _cover = 'http://$sdHost:$SD_PORT/static/img/api-logo.svg';
  String? splashImg;
  Configs txt2img = Configs();

  bool faceFix = DEFAULT_FACE_FIX;
  bool hiresFix = false;

  int batchCount = 1;
  int batchSize = 1;

  // String host =
  bool autoSave = true;
  bool hideNSFW = true;
  bool checkIdentityWhenReEnter = true;

  double upscale = 2;

  int scalerWidth = DEFAULT_WIDTH;
  int scalerHeight = DEFAULT_HEIGHT;

  void loadFromSP(SharedPreferences sp) {

    // share = sp.getBool(SP_SHARE)??false;
    generateType = sp.getInt(SP_GENERATE_TYPE) ?? 1;
    promptType = sp.getInt(SP_PROMPT_TYPE) ?? 3;
    // if (!UniversalPlatform.isIOS) {
    splashImg = '$sdHttpService/favicon.ico';
    // } else {
    //   splashImg = 'https://stability.ai/favicon.ico'; // ios 第一次https 调用才会触发授权弹框
    // }
    // splashImg = 'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';
    txt2img.sampler = sp.getString(SP_SAMPLER) ?? DEFAULT_SAMPLER;
    txt2img.steps = sp.getInt(SP_SAMPLER_STEPS) ?? DEFAULT_SAMPLER_STEPS;
    txt2img.width = sp.getInt(SP_WIDTH) ?? DEFAULT_WIDTH;
    txt2img.height = sp.getInt(SP_HEIGHT) ?? DEFAULT_HEIGHT;
    txt2img.checkedStyles = sp.getStringList(SP_CHECKED_STYLES) ?? [];

    faceFix = sp.getBool(SP_FACE_FIX) ?? DEFAULT_FACE_FIX;
    hiresFix = sp.getBool(SP_HIRES_FIX) ?? DEFAULT_HIRES_FIX;
    batchCount = sp.getInt(SP_BATCH_COUNT) ?? 1;
    batchSize = sp.getInt(SP_BATCH_SIZE) ?? 1;
    autoSave = sp.getBool(SP_AUTO_SAVE) ?? DEFAULT_AUTO_SAVE;
    hideNSFW = sp.getBool(SP_HIDE_NSFW) ?? DEFAULT_HIDE_NSFW;
    checkIdentityWhenReEnter =
        sp.getBool(SP_CHECK_IDENTITY) ?? DEFAULT_CHECK_IDENTITY;
  }

  save() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(SP_SAMPLER, txt2img.sampler);
    await sp.setInt(SP_SAMPLER_STEPS, txt2img.steps);
    await sp.setInt(SP_WIDTH, txt2img.width);
    await sp.setInt(SP_HEIGHT, txt2img.height);
    await sp.setStringList(SP_CHECKED_STYLES, txt2img.checkedStyles);

    await sp.setBool(SP_FACE_FIX, faceFix);
    await sp.setBool(SP_HIRES_FIX, hiresFix);
    await sp.setInt(SP_BATCH_COUNT, batchCount);
    await sp.setInt(SP_BATCH_SIZE, batchSize);
  }

  void updateGenerateType(int type) {
    this.generateType = type;
    notifyListeners();
  }



  void removePluginPrompt(String prefix, String name) {
    txt2img.prompt.replaceAll(getPluginMarch(prefix, name), "");
  }

  void addPluginPrompt(String prefix, String name) {
    txt2img.prompt += "<$prefix:$name:1.0>";
  }

  void updatePrompt(String? prompt) {
    this.txt2img.prompt = prompt ?? "";
    notifyListeners();
  }

  void updatePrompts(String prompt, String negPrompt,
      {int? steps, String? sampler, double? cfgScale, double? seed}) {
    this.txt2img.prompt = prompt;
    this.txt2img.negativePrompt = negPrompt;
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

  void selectSampler(String newValue) {
    txt2img.sampler = newValue;
    notifyListeners();
  }

  void switchChecked(String name) {
    if (txt2img.checkedStyles.contains(name)) {
      txt2img.checkedStyles.remove(name);
    } else {
      txt2img.checkedStyles.add(name);
    }
    notifyListeners();
  }

  void cleanCheckedStyles() {
    txt2img.checkedStyles.clear();
    notifyListeners();
  }

  void replaceChecked(String? old, String? newValue) {
    if (txt2img.checkedStyles.contains(old)) {
      txt2img.checkedStyles.remove(old);
    }
    if (null != newValue) {
      switchChecked(newValue);
    }
  }

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

  unCheckStyles(String style) {
    txt2img.checkedStyles.remove(style);
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

}
