import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/UserInfo.dart';
import 'package:sd/sd/roll/tagger_widget.dart';
import 'package:sd/sd/tavern/bean/ImageSize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/splash_page.dart';
import 'bean/Configs.dart';
import 'bean/PromptStyle.dart';
import 'bean/db/PromptStyleFileConfig.dart';
import 'bean/db/Workspace.dart';
import 'bean4json/UpScaler.dart';
import 'const/config.dart';
import 'db_controler.dart';
import 'http_service.dart';

//存放需要在闪屏页初始化的配置

class AIPainterModel with ChangeNotifier, DiagnosticableTreeMixin {
  static const String TAG = 'AIPainterModel';

  UserInfo userInfo = UserInfo();

  bool sdServiceAvailable = false;
  Workspace? selectWorkspace;
  List<PromptStyleFileConfig>? styleConfigs;

  Map<String, List<PromptStyle>>? publicStyles =
      Map(); // '','privateFilePath'.''

  late Map<String, int> limit = {};
  late Map<String, ImageSize?> imgSize = {};
  List<String> checkedStyles = [];
  List<PromptStyle> _styles = [];

  get styles {
    if (_styles.isEmpty) {
      for (List<PromptStyle> values in publicStyles!.values) {
        _styles.addAll(values);
      }
    }
    return _styles;
  }

  // String _cover =
  //     'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

  // String _cover = 'http://$sdHost:$SD_PORT/static/img/api-logo.svg';
  String? splashImg;

  int countdownNum = SPLASH_WATTING_TIME;
  bool https = false;

  double denoisingStrength = 0.3;

  int resizeWidth = 0;
  int resizeHeight = 0;

  int batchCount = 1;
  int batchSize = 1;

  // String host =
  bool autoSave = true;
  bool hideNSFW = true;

  bool checkIdentityWhenReEnter = true;

  // String selectedSDModel = "";
  String selectedSDModel = "";

  List<UpScaler> upScalers = [];
  String selectedUpScale = DEFAULT_UPSCALE;

  bool faceFix = DEFAULT_FACE_FIX;
  bool tiling = false;
  bool hiresFix = false;
  int hiresSteps = 30;

  double upscale = 2;

  int scalerWidth = DEFAULT_WIDTH;
  int scalerHeight = DEFAULT_HEIGHT;

  Map<String, double> checkedPlugins = Map();

  // Map<String, double> checkedPlugins = Map(); // lora

  String selectedInterrogator = DEFAULT_INTERROGATOR;

  Configs config = Configs();

  late SharedPreferences sp;
  int index = 0;

  void updateIndex(int index) {
    this.index = index;
    notifyListeners();
  }

  load() async {
    // printDir(await getExternalStorageDirectory());  //only for android
    // printDirs(await getExternalCacheDirectories()); // only for android
    // printDirs(await getExternalStorageDirectories()); //only for android
    // printDir(await getDownloadsDirectory()); //only for not android
    printDir(
        await getTemporaryDirectory()); // /data/user/0/edu.tjrac.swant.sd/cache  //AppData/tmp //应用退出后可能被删除
    if (UniversalPlatform.isAndroid) {
      // syncPath = (await getExternalCacheDirectories())!.first.path.toString(); //无法读写
      syncPath = (await getExternalStorageDirectories())!.first.path.toString();
      asyncPath = syncPath;
    } else {
      asyncPath = (await getApplicationSupportDirectory())
          .path
          .toString(); //AppData/Library/Caches //itunes 不会同步
      syncPath = (await getApplicationDocumentsDirectory())
          .path
          .toString(); //AppData/Documents itunes 备份恢复包含
    }
    logt(TAG, asyncPath);
    // /data/user/0/edu.tjrac.swant.sd/files
    logt(TAG, syncPath);
    // /data/user/0/edu.tjrac.swant.sd/app_flutter

    // sp初始化前不该有太多耗时操作
    sp = await SharedPreferences.getInstance();
    sdShareHost = sp.getString(SP_SHARE_HOST) ??'d17eae44-da1d-413c';
    sdHost = sp.getString(SP_HOST) ??
        (Platform.isWindows ? SD_WIN_HOST : SD_CLINET_HOST);
    if (sdShare) {
      sdHttpService = "http://$sdHost.gradio.live";
    } else {
      sdHttpService = "http://$sdHost:$SD_PORT";
    }
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
    autoSave = sp.getBool(SP_AUTO_SAVE) ?? true;
    hideNSFW = sp.getBool(SP_HIDE_NSFW) ?? true;
    checkIdentityWhenReEnter = sp.getBool(SP_CHECK_IDENTITY) ?? true;

    String name = sp.getString(SP_CURRENT_WS) ?? DEFAULT_WORKSPACE_NAME;

// DBController 操作必须在此之后
    Workspace? ws = await DBController.instance.initDepends(workspace: name);
    if (ws == null) {
      ws = Workspace(DEFAULT_WORKSPACE_NAME, getWorkspacesPath());
      int? insertResult = await DBController.instance.insertWorkSpace(ws);
      if (null != insertResult && insertResult >= 0) {
        var config = PromptStyleFileConfig(
            name: "远端配置",
            belongTo: insertResult,
            type: ConfigType.remote.index);
        await DBController.instance.insertStyleFileConfig(config);
        selectWorkspace = ws;
      }
    } else {
      selectWorkspace = ws;
    }
    await DBController.instance.queryAgeLevelRecord()?.then((value) {
      logt(TAG, "limit size${value.length}");
      value.forEach((element) {
        logt(TAG, "ageLevelRecord $element");
        limit.putIfAbsent(element['sign'], () => element['ageLevel']);
      });
      logt(TAG, "limit size${limit.keys}");
    });
    if (null != selectWorkspace?.id) {
      loadStylesFromDB(selectWorkspace!.id!);
    }

    logt(TAG, "load config${selectWorkspace?.dirPath}");
    notifyListeners();

    if (UniversalPlatform.isAndroid) {
      createDirIfNotExit(getCollectionsPath());
      createDirIfNotExit(getStylesPath());
      createDirIfNotExit(getWorkspacesPath());
      await compute(moveDirToAnotherPath,
          FromTo(SYSTEM_DOWNLOAD_APP_PATH, getCollectionsPath()));
    }
  }

  loadStylesFromDB(int wsId) async {
    List? rows = await DBController.instance.queryStyles(wsId);
    if (null != rows && rows.isNotEmpty) {
      styleConfigs = rows.map((e) {
        PromptStyleFileConfig config = PromptStyleFileConfig.fromJson(e);
        config.state = 1;
        return config;
      }).toList();
      for (PromptStyleFileConfig item in styleConfigs!) {
        if (null == item.configPath || item.configPath!.isEmpty) {
          // publicStyles.putIfAbsent('', () =>
          //      CsvToListConverter().convert(csv).);
          get("$sdHttpService$GET_STYLES").then((value) async {
            List re = value?.data;
            List<PromptStyle> remote = re
                // .where((element) => null != element)
                // .toList()
                .map((e) => PromptStyle.fromJson(e))
                .toList();
            logt(TAG, re.toString());

            if (remote[0].isEmpty) {
              PromptStyle? head;
              List<PromptStyle> group = [];
              for (PromptStyle item in remote) {
                if (item.isEmpty) {
                  if (item != head) {
                    if (group.length > 0) {
                      publicStyles?.putIfAbsent(head!.name, () => group);
                      // await File("${getStylesPath()}/${head!.name}.csv")
                      //     .writeAsString(const ListToCsvConverter()
                      //     .convert(PromptStyle.convertPromptStyle(group)));
                    }
                    group = [];
                    head = item;
                  }
                } else {
                  group.add(item);
                }
              }
            } else {
              publicStyles?.putIfAbsent('远端配置', () => remote);
            }
            await File("${getStylesPath()}/remote.csv").writeAsString(
                const ListToCsvConverter()
                    .convert(PromptStyle.convertPromptStyle(remote)));
          });
        } else {
          List<PromptStyle> styles =
              await loadPromptStyleFromCSVFile(item.configPath!);
          publicStyles?.putIfAbsent(item.name!, () => styles);
        }
      }
    }
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

  FutureOr<dynamic> moveDirToAnotherPath(FromTo fromTo) async {
    Directory pubPics = Directory(fromTo.from);
    Directory priPics = Directory(fromTo.to);

    List<FileSystemEntity> entitys = pubPics.listSync();
    try {
      for (FileSystemEntity entity in entitys) {
        if (entity is Directory) {
          await moveChildToAnotherPath(
              getFileName(entity.path), entity.listSync(), priPics);
        }
      }
      logt(TAG, "moveDirToAnotherPath Success");

      return Future.value(1);
    } catch (e) {
      logt(TAG, "moveDirToAnotherPath failed ${e.toString()}");

      return Future.error(-1);
    }
  }

  Future<void> moveChildToAnotherPath(String fileName,
      List<FileSystemEntity> listSync, Directory priPics) async {
    listSync.forEach((element) async {
      if (element is File) {
        String newPath =
            "${priPics.path}/$fileName/${getFileName(element.path)}";
        logt(TAG, "${element.path} $newPath");
        await element.copy(newPath);
        await element.delete();
      }
    });
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

  void updatePrompt(String prompt) {
    this.config.prompt = prompt;
    notifyListeners();
  }

  void updatePrompts(String prompt, String negPrompt) {
    this.config.prompt = prompt;
    this.config.negativePrompt = negPrompt;
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

  String getCheckedPluginsString() {
    String result = "";
    for (String key in checkedPlugins.keys) {
      result += "<$key:${checkedPlugins[key]}>";
    }
    return result;
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

  int limitedUrl(String imgUrl) {
    return limit[imgUrl] ?? 0;
  }

  void updateCheckIdentity(bool value) {
    this.checkIdentityWhenReEnter = value;
    notifyListeners();
  }
}
