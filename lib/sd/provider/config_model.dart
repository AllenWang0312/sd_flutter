import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/bean/options.dart';
import 'package:sd/sd/provider/SPModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/util/file_util.dart';
import '../../platform/platform.dart';
import '../bean/db/Workspace.dart';
import '../const/config.dart';
import '../http_service.dart';

const TAG = 'ConfigModel';

class ConfigModel extends SPModel {
  late SharedPreferences sp;

  bool tiling = false;
  int hiresSteps = 30;

  Map<String, double> checkedPlugins = Map();
  String selectedUpScale = DEFAULT_UPSCALE;


  loadConfig() async {
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
    loadFromSP(sp);

    String name = sp.getString(SP_CURRENT_WS) ?? DEFAULT_WORKSPACE_NAME;

    initConfigFromDB(name);

    notifyListeners();
    // List<String> split = view.split("\r\n");
    // logt(TAG, "view:${split.length} ${split.toString()}");


    createDirIfNotExit(getCollectionsPath());
    createDirIfNotExit(getStylesPath());
    createDirIfNotExit(getWorkspacesPath());
    // await compute(moveDirToAnotherPath,
    //     FromTo(SYSTEM_DOWNLOAD_APP_PATH, getCollectionsPath()));
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

  void updateHiresSteps(double value) {
    hiresSteps = value.toInt();
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

  void updateScalerWidth(double value) {
    scalerWidth = value.toInt();
    notifyListeners();
  }

  void updateScalerHeight(double value) {
    scalerHeight = value.toInt();
    notifyListeners();
  }

  void updateSelectWorkspace(Workspace value) {
    selectWorkspace = value;
    sp.setString(SP_CURRENT_WS, value.name);
    notifyListeners();
  }
}
