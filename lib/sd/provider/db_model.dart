import 'dart:io';
import 'dart:typed_data';

import 'package:dcache/dcache.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/bean/db/PromptStyleFileConfig.dart';
import 'package:sd/sd/bean/db/Workspace.dart';
import 'package:sd/sd/const/default.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/provider/network_model.dart';

const TAG = 'DBModel';

class DBModel extends NetWorkProvider {
  List<PromptStyleFileConfig>? styleConfigs;

  get styles {
    List<PromptStyle> _styles = [];
    // if (_styles.isEmpty) {
    for (List<PromptStyle> values in publicStyles.values) {
      _styles.addAll(values);
    }
    // }
    return _styles;
  }

  Workspace? selectWorkspace;

  late Map<String, int> limit = {};

  int styleFrom = 3;

  void updatePromptType(int newValue) {
    styleFrom = newValue;
    notifyListeners();
  }

  Future<Workspace> initConfigFromDB(String workSpaceName) async {
    // DBController 操作必须在此之后
    Workspace? ws = await DBController.instance
        .initDepends(asyncPath + WORKSPACES, workspace: workSpaceName);

    if (ws == null) {
      ws = Workspace(asyncPath + WORKSPACES, DEFAULT_WORKSPACE_NAME);
      createDirIfNotExit(ws.absPath);
      int insertResult = await DBController.instance.insertWorkSpace(ws);
      if (insertResult >= 0) {
        var config = PromptStyleFileConfig(
            belongTo: insertResult, type: ConfigType.remote.index);
        await DBController.instance.insertStyleFileConfig(config);
      }
    }
    return ws;
  }

  initLocalLimitFromDB() async {
    await DBController.instance.queryAgeLevelRecord()?.then((value) {
      value.forEach((element) {
        limit.putIfAbsent(element['sign'], () => element['ageLevel']);
      });
    });
  }

  Future<List<PromptStyleFileConfig>> loadStylesFromDB(
      int wsId, int userAge) async {
    List? rows = await DBController.instance.queryStyles(wsId);
    if (null != rows && rows.isNotEmpty) {
      return rows.map((e) {
        PromptStyleFileConfig config =
            PromptStyleFileConfig.fromJson(e, getStylesPath());
        config.state = 1;
        return config;
      }).toList();
    }
    return [];
  }

  Future<void> initPublicStyle(
      List<PromptStyleFileConfig>? styleConfigs, int userAge) async {
    if(null==styleConfigs||styleConfigs.isEmpty){
      return initPublicStyleWithNetwork();
    }
    for (PromptStyleFileConfig item in styleConfigs) {
      if (!File(item.configPath).existsSync() ||
          null == item.configPath ||
          item.configPath.isEmpty) {
        return initPublicStyleWithNetwork();
      } else {
        List<PromptStyle> styles =
            await loadPromptStyleFromCSVFile(item.configPath, userAge);
        publicStyles.putIfAbsent(item.name, () => styles);
      }
    }
  }
}
