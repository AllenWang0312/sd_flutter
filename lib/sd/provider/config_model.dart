

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sd/sd/provider/db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/util/file_util.dart';
import '../../platform/platform.dart';
import '../bean/Configs.dart';
import '../bean/db/Workspace.dart';
import '../const/config.dart';
import '../http_service.dart';

const TAG = 'ConfigModel';
class ConfigModel extends DBModel{

  late SharedPreferences sp;
  // String _cover =
  //     'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

  // String _cover = 'http://$sdHost:$SD_PORT/static/img/api-logo.svg';
  String? splashImg;
  Configs config = Configs();
  bool faceFix = DEFAULT_FACE_FIX;
  bool tiling = false;
  bool hiresFix = false;
  int hiresSteps = 30;

  double upscale = 2;
  int batchCount = 1;
  int batchSize = 1;

  // String host =
  bool autoSave = true;
  bool hideNSFW = true;

  bool checkIdentityWhenReEnter = true;

  int scalerWidth = DEFAULT_WIDTH;
  int scalerHeight = DEFAULT_HEIGHT;
  Map<String, double> checkedPlugins = Map();
  String selectedUpScale = DEFAULT_UPSCALE;

  List<String> checkedStyles = [];


  load() async {
    printDir(
        await getTemporaryDirectory()); // /data/user/0/edu.tjrac.swant.sd/cache  //Library/Caches //应用退出后可能被删除

    if (UniversalPlatform.isAndroid) {
      printDir(await getExternalStorageDirectory()); //only for android
      printDirs(await getExternalCacheDirectories()); // only for android
      printDirs(await getExternalStorageDirectories()); //only for android
      // /data/user/0/edu.tjrac.swant.sd/files
      // /data/user/0/edu.tjrac.swant.sd/app_flutter

      // syncPath = (await getExternalCacheDirectories())!.first.path.toString(); //无法读写

      syncPath =
          (await getExternalStorageDirectories())?.first.path.toString() ?? "";
      asyncPath = syncPath;
    } else {
      printDir(
          await getDownloadsDirectory()); //only for not android //Downloads

      // if(UniversalPlatform.isIOS||UniversalPlatform.isMacOS){
      // dir = await getApplicationSupportDirectory(); // Library/Application Support
      // dir = await getApplicationDocumentsDirectory();

      // }else{
      syncPath = (await getApplicationDocumentsDirectory()).path.toString();
      asyncPath = (await getApplicationSupportDirectory()).path.toString();

      // }
    }

    logt(TAG, asyncPath);
    logt(TAG, syncPath);

    // sp初始化前不该有太多耗时操作
    sp = await SharedPreferences.getInstance();
    sdHost = sp.getString(SP_HOST) ??
        (UniversalPlatform.isWindows ? SD_WIN_HOST : SD_CLINET_HOST);
    if (!UniversalPlatform.isIOS) {
      splashImg = 'http://$sdHost:$SD_PORT/favicon.ico';
    } else {
      splashImg = 'https://stability.ai/favicon.ico'; // ios 第一次https 调用才会触发授权弹框
    }
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

    String name = sp.getString(SP_CURRENT_WS) ?? DEFAULT_WORKSPACE_NAME;

    initConfigFromDB(name);

    notifyListeners();

    createDirIfNotExit(getCollectionsPath());
    createDirIfNotExit(getStylesPath());
    createDirIfNotExit(getWorkspacesPath());
    // await compute(moveDirToAnotherPath,
    //     FromTo(SYSTEM_DOWNLOAD_APP_PATH, getCollectionsPath()));
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


  printDir(Directory? dir) {
    if (null != dir) {
      logt(TAG, "download path" + dir.path.toString());
    }
  }

  printDirs(List<Directory>? dirs) {
    if (null != dirs) {
      logt(TAG, "print path:" + dirs.toString());
    }
  }


  static RegExp getPluginMarch(String prefix, String name) {
    return RegExp(r"<" + prefix + ":" + name + ":+([0-1]\.\d)>+");
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
    if(null!=steps) this.config.steps = steps;
    if(null!=sampler) this.config.sampler = sampler;
    if(null!=cfgScale) this.config.cfgScale = cfgScale;
    if(null!=seed) this.config.seed = seed.toInt();

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

  void setTiling(bool bool) {
    tiling = bool;
    notifyListeners();
  }

  void updateScaleMethod(String newValue) {
    selectedUpScale = newValue;
    notifyListeners();
  }

  void updateSteps(double value) {
    config.steps = value.toInt();
    notifyListeners();
  }

  void updateHiresSteps(double value) {
    hiresSteps = value.toInt();
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

  void updateWidth(double value) {
    config.width = value.toInt();
    if (hiresFix) {
      scalerWidth = (upscale * config.width).toInt();
    }
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

  cleanCheckedStyles() {
    checkedStyles.clear();
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
    scalerWidth = (config.width * upscale).toInt();
    scalerHeight = (config.height * upscale).toInt();
    notifyListeners();
  }

  void cleanPrompts() {
    config = Configs();
    notifyListeners();
  }

  void updateSelectWorkspace(Workspace value) {
    selectWorkspace = value;
    sp.setString(SP_CURRENT_WS, value.name);
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