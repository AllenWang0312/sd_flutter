import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sd/sd/provider/SPModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/util/file_util.dart';
import '../../platform/platform.dart';
import '../bean/PromptStyle.dart';
import '../bean/db/Workspace.dart';
import '../bean/options.dart';
import '../const/config.dart';
import '../db_controler.dart';
import '../http_service.dart';
import '../mocker.dart';

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

    // logt(TAG, asyncPath);
    // logt(TAG, syncPath);

    // sp初始化前不该有太多耗时操作
    sp = await SharedPreferences.getInstance();

    if(null==sdHttpService){
      String host = 'raw.githubusercontent.com';
      String githubSetting = sp.getString(SP_ALT_ADDRESS) ??
          "https://$host/AllenWang0312/mock/sd_flutter/alt.json";
      get(githubSetting, exceptionCallback: (e) {
        initNetworkConfig(sp);
      }).then((value) {
        List? services = value?.data['services'];
        if (null != services && services.isNotEmpty) {
          logt(TAG,services.toString());
          sdHttpService = services[0];
        }
        initNetworkConfig(sp);
      });
    }else{
      initNetworkConfig(sp);
    }


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

  Future<void> networkInitPromptStyle() async {
    if (null != selectWorkspace?.id) {
      if (promptType == 2) {
        await loadStylesFromDB(selectWorkspace!.id!);
      } else if (promptType == 3) {
        String? csv;
        for (int i = 0;i<3; i++) {
          // try {
          //   // csv = await rootBundle.loadString("assets/csv/$i.csv");
          // } catch (e) {
          //   logt(TAG, e.toString());
          //   break;
          // }
          get("$sdHttpService$TAG_MY_TAGS/$i.csv",exceptionCallback: (e){
            return;
          }).then((value){
            if(null!=value&&null!=value.data){
              csv = value.data.toString();
              List<PromptStyle> styles = loadPromptStyleFromString(csv!, flag: i);//todo 这里根据i 区分执行步骤 用户配置 3.4... 时 都会被视为细节
              publicStyles?.putIfAbsent(i.toString(), () => styles);
              // PromptStyle? head;
              logt(TAG, styles.toString());
              Optional? target;
              for (PromptStyle item in styles) {
                if (item.isEmpty) {
                  // head = item;
                  // logt(TAG," ${target?.name}");
                  target = optional.createIfNotExit(
                      item.name.contains("|") ? item.name.split('|') : [item.name]);
                } else {
                  // logt(TAG," ${target?.name} ${item.name}");
                  target?.addOption(item.name, getOptionalWithName(item.name));
                }
              }
            }
          });
        }
        logt(TAG, optional.toString());
      }
    }
  }

  void networkInitTranlates(){
    get("$sdHttpService$TAG_COMPUTE_CN").then((value) async {
      if (null != value) {
        List<List<dynamic>> csvTable = CsvToListConverter().convert(value.data);
        int year = 0;
        for (List<dynamic> item in csvTable) {
          if (item[0] is int && item[0] == item[2]) {
            year = item[0];
          }else{
            // todo 第二次全量插入 第一条就直接报错了 所以不能根据远端配置动态升级
            int result = await DBController.instance.insertTranslate(item,year);
          }
        }
        logt(TAG,"insert translate finish");
      }
    });
  }
  void networkInitApiOptions(){

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
