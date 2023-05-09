import 'dart:math';

import 'package:sd/sd/provider/db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../bean/Configs.dart';
import '../const/config.dart';
import '../http_service.dart';

const TAG = "SPModel";

class SPModel extends DBModel {
  bool share = false;
  int generateType = 1; //单次请求接口方式 0 优先api 1 优先predict
  // String _cover =
  //     'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

  // String _cover = 'http://$sdHost:$SD_PORT/static/img/api-logo.svg';
  String? splashImg;
  Configs config = Configs();
  bool faceFix = DEFAULT_FACE_FIX;
  bool hiresFix = false;
  List<String> checkedStyles = [];

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

    generateType = sp.getInt(SP_GENERATE_TYPE) ?? 1;
    promptType = sp.getInt(SP_PROMPT_TYPE) ?? 3;
    // if (!UniversalPlatform.isIOS) {
    splashImg = '$sdHttpService/favicon.ico';
    // } else {
    //   splashImg = 'https://stability.ai/favicon.ico'; // ios 第一次https 调用才会触发授权弹框
    // }
    // splashImg = 'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';
    config.sampler = sp.getString(SP_SAMPLER) ?? DEFAULT_SAMPLER;
    config.steps = sp.getInt(SP_SAMPLER_STEPS) ?? DEFAULT_SAMPLER_STEPS;
    config.width = sp.getInt(SP_WIDTH) ?? DEFAULT_WIDTH;
    config.height = sp.getInt(SP_HEIGHT) ?? DEFAULT_HEIGHT;

    faceFix = sp.getBool(SP_FACE_FIX) ?? DEFAULT_FACE_FIX;
    hiresFix = sp.getBool(SP_HIRES_FIX) ?? DEFAULT_HIRES_FIX;
    checkedStyles = sp.getStringList(SP_CHECKED_STYLES) ?? [];
    batchCount = sp.getInt(SP_BATCH_COUNT) ?? 1;
    batchSize = sp.getInt(SP_BATCH_SIZE) ?? 1;
    autoSave = sp.getBool(SP_AUTO_SAVE) ?? DEFAULT_AUTO_SAVE;
    hideNSFW = sp.getBool(SP_HIDE_NSFW) ?? DEFAULT_HIDE_NSFW;
    checkIdentityWhenReEnter =
        sp.getBool(SP_CHECK_IDENTITY) ?? DEFAULT_CHECK_IDENTITY;
  }

  save() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(SP_SAMPLER, config.sampler);
    await sp.setInt(SP_SAMPLER_STEPS, config.steps);
    await sp.setInt(SP_WIDTH, config.width);
    await sp.setInt(SP_HEIGHT, config.height);

    await sp.setBool(SP_FACE_FIX, faceFix);
    await sp.setBool(SP_HIRES_FIX, hiresFix);
    await sp.setStringList(SP_CHECKED_STYLES, checkedStyles);
    await sp.setInt(SP_BATCH_COUNT, batchCount);
    await sp.setInt(SP_BATCH_SIZE, batchSize);
  }

  static RegExp getPluginMarch(String prefix, String name) {
    return RegExp(r"<" + prefix + ":" + name + ":+([0-1]\.\d)>+");
  }

  void updateGenerateType(int type) {
    this.generateType = type;
    notifyListeners();
  }

  void updateShare(bool share) {
    this.share = share;
    notifyListeners();
  }

  void removePluginPrompt(String prefix, String name) {
    config.prompt.replaceAll(getPluginMarch(prefix, name), "");
  }

  void addPluginPrompt(String prefix, String name) {
    config.prompt += "<$prefix:$name:1.0>";
  }

  void updatePrompt(String? prompt) {
    this.config.prompt = prompt ?? "";
    notifyListeners();
  }

  void updatePrompts(String prompt, String negPrompt,
      {int? steps, String? sampler, double? cfgScale, double? seed}) {
    this.config.prompt = prompt;
    this.config.negativePrompt = negPrompt;
    if (null != steps) this.config.steps = min(100, steps);
    if (null != sampler) this.config.sampler = sampler;
    if (null != cfgScale) this.config.cfgScale = cfgScale;
    if (null != seed) this.config.seed = seed.toInt();

    notifyListeners();
  }

  void updateConfigs(Configs prompt) {
    this.config = prompt;
    notifyListeners();
  }

  void updateNegPrompt(String negPrompt) {
    this.config.negativePrompt = negPrompt;
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
    config.steps = value.toInt();
    notifyListeners();
  }

  void selectSampler(String newValue) {
    config.sampler = newValue;
    notifyListeners();
  }

  void switchChecked(String name) {
    if (checkedStyles.contains(name)) {
      checkedStyles.remove(name);
    } else {
      checkedStyles.add(name);
    }
    notifyListeners();
  }

  void cleanCheckedStyles() {
    checkedStyles.clear();
    notifyListeners();
  }

  void replaceChecked(String? old, String? newValue) {
    if (checkedStyles.contains(old)) {
      checkedStyles.remove(old);
    }
    if (null != newValue) {
      switchChecked(newValue);
    }
  }

  void updateWidth(double value) {
    config.width = value.toInt();
    if (hiresFix) {
      scalerWidth = (upscale * config.width).toInt();
    }
    notifyListeners();
  }

  void updateScale(double value) {
    upscale = value;
    scalerWidth = (config.width * upscale).toInt();
    scalerHeight = (config.height * upscale).toInt();
    notifyListeners();
  }

  void cleanPrompts() {
    config = Configs();
    notifyListeners();
  }

  void updateHeight(double value) {
    config.height = value.toInt();
    if (hiresFix) {
      scalerHeight = (upscale * config.height).toInt();
    }
    notifyListeners();
  }

  unCheckStyles(String style) {
    checkedStyles.remove(style);
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

  void initNetworkConfig(SharedPreferences sp) {
    if (null==sdHttpService||sdHttpService!.isEmpty) {
      share = sp.getBool(SP_SHARE) ?? false;
      if (share) {
        sdPublicDomain = sp.getString(SP_SHARE_HOST);
        sdHttpService = "https://$sdPublicDomain.gradio.live";
      } else {
        sdHost = sp.getString(SP_HOST) ??
            (UniversalPlatform.isWindows ? SD_WIN_HOST : SD_CLINET_HOST);
        sdHttpService = "http://$sdHost:$SD_PORT";
      }
    } else {
      share = true;
      sdPublicDomain = sdHttpService!.substring(8, sdHttpService!.length - 13);
      sp.setBool(SP_SHARE, true);
      sp.setString(SP_SHARE_HOST, sdPublicDomain!);
    }
  }
}
