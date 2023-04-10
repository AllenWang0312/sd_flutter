import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/db_controler.dart';

import '../bean/PromptStyle.dart';
import '../bean/db/PromptStyleFileConfig.dart';
import '../bean/db/Workspace.dart';
import '../config.dart';
import '../file_util.dart';
import '../http_service.dart';
import '../ui_util.dart';
import 'PathProviderWidget.dart';

class CreateWSModel with ChangeNotifier, DiagnosticableTreeMixin {
  StorageType? storageType = StorageType.Public;

  StyleResType? styleResType = StyleResType.reomote;
  String styleConfigPath = "";

  void updateStorageType(StorageType storageType) {
    this.storageType = storageType;
    notifyListeners();
  }

  void updateStyleResType(StyleResType? value, String path) {
    this.styleConfigPath = path;
    this.styleResType = value!;
    notifyListeners();
  }
}

final String TAG = "CreateWorkspaceWidget";

class CreateWorkspaceWidget extends PathProviderWidget {
  Workspace? workspace;
  List<Workspace>? otherWorkspaces;

  CreateWorkspaceWidget(
      String applicationPath, String publicPath, String openHidePath,
      {this.workspace, this.otherWorkspaces})
      : super(applicationPath, publicPath, openHidePath);

  late CreateWSModel model;
  late TextEditingController controller;
  late TextEditingController pathController;

  @override
  Widget build(BuildContext context) {
    // publicPath = removePrePathIfIsPublic(publicPath);
    // openHidePath = removePrePathIfIsPublic(openHidePath);
    model = Provider.of<CreateWSModel>(context, listen: false);
    pathController = TextEditingController(
        text: workspace == null ? '' : workspace?.dirPath);

    controller = TextEditingController(
        text: workspace == null ? '' : workspace?.getName());
    controller.addListener(() {
      pathController.text = getStoragePath(model.storageType, controller.text);
      model.updateStyleResType(
          model.styleResType, "$applicationPath/${controller.text}/styles.csv");
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(workspace == null ? '创建工作空间' : '修改工作空间配置'),
        actions: [
          IconButton(
              onPressed: () async {
                if (controller.text != null) {
                  if (createDirIfNotExit(pathController.text)) {
                    var nw = Workspace(controller.text, pathController.text);
                    if (model.styleResType == StyleResType.reomote) {
                      if (await DBController.instance.insertWorkSpace(nw) > 0) {
                        Navigator.pop(context, nw);
                      }
                    } else {
                      // select source
                      File? csvFile = await showModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          constraints: const BoxConstraints.expand(height: 98),
                          builder: (context) {
                            return Column(
                              children: optionsDataFrom(
                                  context, model.styleConfigPath),
                            );
                          });
                      if (null != csvFile) {
                        nw.stylesConfigFilePath = csvFile.path;
                        int id =
                            await DBController.instance.insertWorkSpace(nw);
                        if (id > 0 &&
                            await DBController.instance.insertStyleFileConfig(
                                    PromptStyleFileConfig(
                                        name: nw.name + "的配置文件",
                                        type: 1,
                                        belongTo: id,
                                        configPath: csvFile.path)) >
                                0) {
                          Navigator.pop(context, nw);
                        }
                      }
                    }
                  } else {
                    Fluttertoast.showToast(msg: "文件夹创建失败");
                  }
                }
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('名称'),
            TextField(
              controller: controller,
            ),
            Text('存储路径'),
            Selector<CreateWSModel, StorageType?>(
              selector: (_, model) => model.storageType,
              builder: (context, value, child) {
                return Column(
                  children: [
                    RadioListTile<StorageType>(
                        title: Text('公共(系统可见)'),
                        value: StorageType.Public,
                        groupValue: value,
                        onChanged: onRadioChanged),
                    RadioListTile<StorageType>(
                        title: Text('公共(其他应用不可见，方便移动文件)'),
                        value: StorageType.Hide,
                        groupValue: value,
                        onChanged: onRadioChanged),
                    RadioListTile<StorageType>(
                        title: Text('应用私有(应用卸载即删除)'),
                        value: StorageType.Private,
                        groupValue: value,
                        onChanged: onRadioChanged),
                  ],
                );
              },
            ),
            TextField(
              controller: pathController,
            ),
            Text('独立样式'),
            Text('样式数据源'),
            Selector<CreateWSModel, StyleResType?>(
              selector: (_, model) => model.styleResType,
              builder: (context, value, child) {
                return Column(
                  children: [
                    RadioListTile<StyleResType>(
                        title: Text('远程配置'),
                        value: StyleResType.reomote,
                        groupValue: value,
                        onChanged: (value) {
                          model.updateStyleResType(value, "");
                        }),
                    RadioListTile<StyleResType>(
                        title: Text('其他工作空间'),
                        value: StyleResType.copy,
                        groupValue: value,
                        onChanged: (value) {
                          //todo 选择工作空间
                          model.updateStyleResType(
                              value,
                              // "$applicationPath/${controller.text}/styles.csv"// todo default styles config file path
                              "$applicationPath/${controller.text}/styles.csv" // todo default styles config file path
                              );
                        }),
                    Offstage(
                        offstage: value != StyleResType.copy, child: child!),
                  ],
                );
              },
              child: Selector<CreateWSModel, String>(
                selector: (_, model) => model.styleConfigPath,
                builder: (context, value, child) {
                  return SelectableText(value); //暂时不开发自定义 跟随图片存储路径
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> optionsDataFrom(BuildContext context, String styleConfigPath) {
    List<Widget> widgets = [];
    widgets.add(bottomSheetItem("复制远端配置", () async {
      get("$sdHttpService$GET_STYLES", exceptionCallback: (e) {
        Fluttertoast.showToast(msg: "请求失败：${e.toString()}");
      }).then((value) async {
        // if(!Directory("/storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/Pictures/小豚鼠/styles.csv").existsSync()){
        //   Directory("/storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/Pictures").createSync();
        // }
        // if(!Directory("/storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/Pictures/小豚鼠").existsSync()){
        //   Directory("/storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/Pictures/小豚鼠").createSync();
        // }
        // if(!File("/storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/Pictures/小豚鼠/styles.csv").existsSync()){
        //   File("/storage/emulated/0/Android/data/edu.tjrac.swant.sd/files/Pictures/小豚鼠/styles.csv").createSync();
        // }
        File f = File(styleConfigPath);

        if (!f.existsSync()) {
          File(styleConfigPath).createSync(recursive: true, exclusive: true);
        }
        if (f.existsSync()) {
          List re = value?.data as List;
          // provider.styles = re.map((e) => PromptStyle.fromJson(e)).toList();
          // 生成csv文件，csv文件路径：缓存目录下的 ble文件夹下
          try {
            String csv =
                const ListToCsvConverter().convert(PromptStyle.convert(re));
            File csvFile = await f.writeAsString(csv);
            Navigator.pop(context, csvFile);
          } catch (e) {}
        }
      });
      // Navigator.pop(context);
    }));
    if (otherWorkspaces != null && otherWorkspaces!.length > 0) {
      for (Workspace item in otherWorkspaces!) {
        widgets.add(bottomSheetItem("复制远端配置", () async {
          Navigator.pop(context);
        }));
      }
    }
    return widgets;
  }

  void onRadioChanged(StorageType? value) {
    logt(TAG,value.toString());
    if (workspace == null) {
      pathController.text = getStoragePath(value, controller.text);
    } else {}
    model.updateStorageType(value!);
  }
}
