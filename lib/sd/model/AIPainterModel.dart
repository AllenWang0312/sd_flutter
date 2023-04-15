import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sd/android.dart';
import 'package:sd/sd/file_util.dart';
import 'package:sd/sd/fragment/tagger_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/splash_page.dart';
import '../bean/PromptStyle.dart';
import '../bean/UpScaler.dart';
import '../bean/db/Workspace.dart';
import '../config.dart';
import '../db_controler.dart';
import '../http_service.dart';

String appendCommaIfNotExist(String str) {
  if (str.isEmpty || str.endsWith(",") || str.endsWith("，")) {
    return str;
  } else {
    return "$str,";
  }
}

//存放需要在闪屏页初始化的配置

class AIPainterModel with ChangeNotifier, DiagnosticableTreeMixin {
  static const String TAG = 'AIPainterModel';

  Workspace? selectWorkspace;

  String splashImg = "";

  int countdownNum = SPLASH_WATTING_TIME;
  bool https = false;

  double denoisingStrength = 0.3;

  int resizeWidth = 0;
  int resizeHeight = 0;

  int batchCount = 1;
  int batchSize = 1;
  double CFGScale = 7.0;
  int seed = -1;

  // String host =
  bool autoSave = true;

  // String selectedSDModel = "";
  String selectedSDModel = "";
  String selectedSampler = DEFAULT_SAMPLER;
  int samplerSteps = DEFAULT_SAMPLER_STEPS;

  List<UpScaler> upScalers = [];
  String selectedUpScale = DEFAULT_UPSCALE;

  bool faceFix = DEFAULT_FACE_FIX;
  bool tiling = false;
  bool hiresFix = false;
  int hiresSteps = 30;

  int width = DEFAULT_WIDTH;
  int height = DEFAULT_HEIGHT;

  double upscale = 2;

  int scalerWidth = DEFAULT_WIDTH;
  int scalerHeight = DEFAULT_HEIGHT;

  List<PromptStyle> styles = [];
  List<String> checkedStyles = [];
  Map<String, double> checkedPlugins = Map();

  // Map<String, double> checkedPlugins = Map(); // lora

  String selectedInterrogator = DEFAULT_INTERROGATOR;
  String prompt = "";
  String negPrompt = "";
  late SharedPreferences sp;

  load() async {
    sp = await SharedPreferences.getInstance();
    sdHost = sp.getString(SP_HOST) ??
        (Platform.isWindows ? SD_WIN_HOST : SD_CLINET_HOST);
    splashImg = 'http://$sdHost:$SD_PORT/favicon.ico';

    selectedSampler = sp.getString(SP_SAMPLER) ?? DEFAULT_SAMPLER;
    samplerSteps = sp.getInt(SP_SAMPLER_STEPS) ?? DEFAULT_SAMPLER_STEPS;
    width = sp.getInt(SP_WIDTH) ?? DEFAULT_WIDTH;
    height = sp.getInt(SP_HEIGHT) ?? DEFAULT_HEIGHT;
    faceFix = sp.getBool(SP_FACE_FIX) ?? DEFAULT_FACE_FIX;
    hiresFix = sp.getBool(SP_HIRES_FIX) ?? DEFAULT_HIRES_FIX;
    checkedStyles = sp.getStringList(SP_CHECKED_STYLES) ?? [];
    batchCount = sp.getInt(SP_BATCH_COUNT) ?? 1;
    batchSize = sp.getInt(SP_BATCH_SIZE) ?? 1;
    String name = sp.getString(SP_CURRENT_WS) ?? DEFAULT_WORKSPACE_NAME;
    Workspace? ws = await DBController.instance.initDepends(workspace: name);
    if (ws == null) {
      ws = Workspace(DEFAULT_WORKSPACE_NAME,
          await getAutoSaveAbsPath()); // /storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/styles/$DEFAULT_WORKSPACE_NAME.csv
      int? insertResult = await DBController.instance.insertWorkSpace(ws);
      if (null != insertResult && insertResult >= 0) {
        selectWorkspace = ws;
      }
    } else {
      selectWorkspace = ws;
    }

    logt(TAG, "load config${selectWorkspace?.dirPath}");
    notifyListeners();
  }

  save() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(SP_SAMPLER, selectedSampler);
    await sp.setInt(SP_SAMPLER_STEPS, samplerSteps);
    await sp.setInt(SP_WIDTH, width);
    await sp.setInt(SP_HEIGHT, height);
    await sp.setBool(SP_FACE_FIX, faceFix);
    await sp.setBool(SP_HIRES_FIX, hiresFix);
    await sp.setStringList(SP_CHECKED_STYLES, checkedStyles);
    await sp.setInt(SP_BATCH_COUNT, batchCount);
    await sp.setInt(SP_BATCH_SIZE, batchSize);
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

  static RegExp getPluginMarch(String prefix, String name) {
    return RegExp(r"<" + prefix + ":" + name + ":+([0-1]\.\d)>+");
  }

  void removePluginPrompt(String prefix, String name) {
    prompt.replaceAll(getPluginMarch(prefix, name), "");
  }

  void addPluginPrompt(String prefix, String name) {
    prompt += "<$prefix:$name:1.0>";
  }

  void updatePrompt(String prompt) {
    this.prompt = prompt;
    notifyListeners();
  }

  void updatePrompts(String prompt, String negPrompt) {
    this.prompt = prompt;
    this.negPrompt = negPrompt;
    notifyListeners();
  }

  void updateNegPrompt(String negPrompt) {
    this.negPrompt = negPrompt;
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

  void setTiling(bool bool) {
    tiling = bool;
    notifyListeners();
  }

  void updateScaleMethod(String newValue) {
    selectedUpScale = newValue;
    notifyListeners();
  }

  void updateSteps(double value) {
    samplerSteps = value.toInt();
    notifyListeners();
  }

  void updateHiresSteps(double value) {
    hiresSteps = value.toInt();
    notifyListeners();
  }

  void selectSampler(String newValue) {
    selectedSampler = newValue;
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

  void updateWidth(double value) {
    width = value.toInt();
    if (hiresFix) {
      scalerWidth = (upscale * width).toInt();
    }
    notifyListeners();
  }

  void updateHeight(double value) {
    height = value.toInt();
    if (hiresFix) {
      scalerHeight = (upscale * height).toInt();
    }
    notifyListeners();
  }

  updateSDModel(String model) {
    selectedSDModel = model;
    logt(TAG, model);
    notifyListeners();
  }

  unCheckStyles(String style) {
    checkedStyles.remove(style);
    notifyListeners();
  }

  cleanCheckedStyles() {
    checkedStyles.clear();
  }

  refreshStyles(List<String> choices) {
    checkedStyles.forEach((element) {
      if (!choices.contains(element)) {
        checkedStyles.remove(element);
      }
    });
    notifyListeners();
  }

  countDown() {
    countdownNum--;
    notifyListeners();
  }

  void selectInterrogator(newValue) {
    selectedInterrogator = newValue;
    notifyListeners();
  }

  void updateScalerWidth(double value) {
    scalerWidth = value.toInt();
    notifyListeners();
  }

  void updateScalerHeight(double value) {
    scalerHeight = value.toInt();
    notifyListeners();
  }

  void updateScale(double value) {
    upscale = value;
    scalerWidth = (width * upscale).toInt();
    scalerHeight = (height * upscale).toInt();
    notifyListeners();
  }

  String getCheckedPluginsString() {
    String result = "";
    for (String key in checkedPlugins.keys) {
      result += "<$key:${checkedPlugins[key]}>";
    }
    return result;
  }

  void cleanPrompts() {
    prompt = '';
    negPrompt = '';
    notifyListeners();
  }

  void updateSelectWorkspace(Workspace value) {
    selectWorkspace = value;
    sp.setString(SP_CURRENT_WS, value.name);
    notifyListeners();
  }
}
