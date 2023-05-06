import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/splash_page.dart';
import '../../common/util/file_util.dart';
import '../../platform/platform.dart';
import '../bean/PromptStyle.dart';
import '../bean/db/PromptStyleFileConfig.dart';
import '../bean/db/Workspace.dart';
import '../const/config.dart';
import '../db_controler.dart';
import '../http_service.dart';

const TAG = 'DBModel';

class DBModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<PromptStyleFileConfig>? styleConfigs;
  Map<String, List<PromptStyle>>? publicStyles = Map(); // '','privateFilePath'.''


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
      logt(TAG, "limit size${value.length}");
      value.forEach((element) {
        logt(TAG, "ageLevelRecord $element");
        limit.putIfAbsent(element['sign'], () => element['ageLevel']);
      });
      logt(TAG, "limit size${limit.keys}");
    });
    if (null != selectWorkspace?.id) {
      await loadStylesFromDB(selectWorkspace!.id!);
    }

    logt(TAG, "load config${selectWorkspace?.absPath}");
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
      for (PromptStyleFileConfig item in styleConfigs!) {
        if (!File(item.configPath).existsSync()||null == item.configPath || item.configPath!.isEmpty) {
          get("$sdHttpService$GET_STYLES").then((value) async {
            List re = value?.data;
            List<PromptStyle> remote = re
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
}
