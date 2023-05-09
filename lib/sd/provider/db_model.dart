import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../common/util/file_util.dart';
import '../../platform/platform.dart';
import '../bean/PromptStyle.dart';
import '../bean/db/PromptStyleFileConfig.dart';
import '../bean/db/Workspace.dart';
import '../bean/options.dart';
import '../const/config.dart';
import '../db_controler.dart';
import '../http_service.dart';

const TAG = 'DBModel';

class DBModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<PromptStyleFileConfig>? styleConfigs;

  Map<String, List<PromptStyle>>? publicStyles =
      Map(); // '','privateFilePath'.''

  Optional optional = Optional('');

  get styles {
    List<PromptStyle> _styles = [];
    // if (_styles.isEmpty) {
    for (List<PromptStyle> values in publicStyles!.values) {
      _styles.addAll(values);
    }
    // }
    return _styles;
  }

  Workspace? selectWorkspace;
  late Map<String, int> limit = {};

  int promptType =3;

  void updatePromptType(int newValue){
    promptType = newValue;
    notifyListeners();
  }

  initConfigFromDB(String workSpaceName) async {
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
        selectWorkspace = ws;
      }
    } else {
      selectWorkspace = ws;
    }
    await DBController.instance.queryAgeLevelRecord()?.then((value) {
      // logt(TAG, "limit size${value.length}");
      value.forEach((element) {
        // logt(TAG, "ageLevelRecord $element");
        limit.putIfAbsent(element['sign'], () => element['ageLevel']);
      });
      // logt(TAG, "limit size${limit.keys}");
    });
    if (null != selectWorkspace?.id) {
      if (promptType == 2) {
        await loadStylesFromDB(selectWorkspace!.id!);
      } else if (promptType == 3) {
        String csv;
        for (int i = 0;; i++) {
          try {
            csv = await rootBundle.loadString("assets/csv/$i.csv");
          } catch (e) {
            logt(TAG, e.toString());
            break;
          }

          List<PromptStyle> styles = loadPromptStyleFromString(csv, flag: i);
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
        logt(TAG, optional.toString());
      }
    }
    // logt(TAG, "load config${selectWorkspace?.absPath}");
  }

  loadStylesFromDB(int wsId) async {
    List? rows = await DBController.instance.queryStyles(wsId);
    if (null != rows && rows.isNotEmpty) {
      styleConfigs = rows.map((e) {
        PromptStyleFileConfig config =
            PromptStyleFileConfig.fromJson(e, getStylesPath());
        config.state = 1;
        return config;
      }).toList();
      initPublicStyle(styleConfigs);
    }
  }

  Future<void> initPublicStyle(
      List<PromptStyleFileConfig>? styleConfigs) async {
    for (PromptStyleFileConfig item in styleConfigs!) {
      if (!File(item.configPath).existsSync() ||
          null == item.configPath ||
          item.configPath!.isEmpty) {
        get("$sdHttpService$GET_STYLES").then((value) async {
          List re = value?.data;
          List<PromptStyle> remote =
              re.map((e) => PromptStyle.fromJson(e)).toList();
          // logt(TAG, re.toString());
          if (remote[0].isEmpty) {
            PromptStyle? head;
            List<PromptStyle> group = [];
            for (PromptStyle item in remote) {
              if (item.isEmpty) {
                if (item != head) {
                  if (group.length > 0) {
                    publicStyles?.putIfAbsent(head!.name, () => group);
                    await File("${getStylesPath()}/${head!.name}.csv")
                        .writeAsString(const ListToCsvConverter()
                            .convert(PromptStyle.convertPromptStyle(group)));
                  }
                  group = [];
                  head = item;
                }
              } else {
                group.add(item);
              }
            }
          } else {
            publicStyles?.putIfAbsent('remote', () => remote);
          }
          await File("${getStylesPath()}/remote.csv").writeAsString(
              const ListToCsvConverter()
                  .convert(PromptStyle.convertPromptStyle(remote)));
        });
      } else {
        List<PromptStyle> styles =
            await loadPromptStyleFromCSVFile(item.configPath);
        publicStyles?.putIfAbsent(item.name, () => styles);
      }
    }
  }
}
