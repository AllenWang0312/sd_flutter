import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/AIPainterModel.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/third_util.dart';
import '../../common/android.dart';
import '../bean/db/PromptStyleFileConfig.dart';
import '../bean/db/Workspace.dart';
import '../bean/enum/StorageType.dart';
import '../bean/enum/StyleResType.dart';
import '../../common/util/file_util.dart';
import '../http_service.dart';
import 'CreateWrokspaceModel.dart';
import '../../common/util/ui_util.dart';
import 'create_style_page.dart';

final String TAG = "CreateWorkspaceWidget";

class CreateWorkspaceWidget extends StatefulWidget {
  late String imgSavePath;
  late String styleSavePath;

  late String? publicPath;
  late String? openHidePath;

  Workspace? workspace;
  List<PromptStyleFileConfig>? configs;
  List<FileSystemEntity>? publicStyleConfigs;

  CreateWorkspaceWidget(this.imgSavePath, this.styleSavePath,
      {this.publicPath,
      this.openHidePath,
      this.workspace,
      this.configs,
      this.publicStyleConfigs});

  @override
  State<CreateWorkspaceWidget> createState() => _CreateWorkspaceWidgetState();
}

class _CreateWorkspaceWidgetState extends State<CreateWorkspaceWidget> {
  String getStoragePath(StorageType? value, String name) {
    if (value == StorageType.Public) {
      return "${widget.publicPath}/$name";
    } else if (value == StorageType.Hide) {
      return "${widget.openHidePath}/$name";
    } else {
      return "${widget.imgSavePath}/$name";
    }
  }

  late AIPainterModel provider;
  late CreateWSModel model;
  late TextEditingController controller;
  late TextEditingController pathController;

  @override
  void reassemble() {
    logt(TAG, "reassemble");
  }

  @override
  Widget build(BuildContext context) {
    logt(TAG, "build");
    logt(TAG, widget.configs?.toString() ?? "null");
    // publicPath = removePrePathIfIsPublic(publicPath);
    // openHidePath = removePrePathIfIsPublic(openHidePath);
    provider = Provider.of<AIPainterModel>(context, listen: false);
    model = Provider.of<CreateWSModel>(context, listen: false);
    if (null != widget.configs) {
      model.allConfig = widget.configs!;
      model.styleResType = StyleResType.public;
      model.notifyListeners();
    }
    if (UniversalPlatform.isAndroid) {
      model.noMediaFileExist =
          File("$ANDROID_PUBLIC_PICTURES_NOMEDIA/.nomedia").existsSync();
    }
    pathController = TextEditingController(
        text: widget.workspace == null ? '' : widget.workspace?.dirPath);

    controller = TextEditingController(
        text: widget.workspace == null ? '' : widget.workspace?.getName());
    controller.addListener(() {
      pathController.text = getStoragePath(model.storageType, controller.text);
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.workspace == null ? '创建工作空间' : '修改工作空间配置'),
        actions: [
          IconButton(
              onPressed: () async {
                if (widget.workspace == null) {
                  if (controller.text.isNotEmpty) {
                    if (await checkStoragePermission()) {
                      if (createDirIfNotExit(pathController.text)) {
                        var nw =
                            Workspace(controller.text, pathController.text);
                        int id =
                            await DBController.instance.insertWorkSpace(nw);

                        if (model.styleResType == StyleResType.reomote) {
                          //远端
                          if (await DBController.instance.insertWorkSpace(nw) >
                              0) {
                            Navigator.pop(context, nw);
                          }
                        } else {
                          //现有引用
                          for (PromptStyleFileConfig config
                              in model.allConfig) {
                            if (config.state == -1) {
                              DBController.instance.removeStyleFileConfigWith(
                                  config.belongTo!, config.configPath!);
                            } else if (config.state == 2) {
                              if (id > 0 &&
                                  await DBController.instance
                                          .insertStyleFileConfig(
                                              PromptStyleFileConfig(
                                                  name: config.name,
                                                  type: ConfigType.public.index,
                                                  belongTo: id,
                                                  configPath:
                                                      config.configPath)) >
                                      0) {}
                            }
                          }
                          Navigator.pop(context, nw);
                        }
                      } else {
                        Fluttertoast.showToast(msg: "文件夹创建失败",gravity: ToastGravity.CENTER);
                      }
                    }
                  } else {
                    Fluttertoast.showToast(msg: "文件夹创建失败",gravity: ToastGravity.CENTER);
                  }
                } else {
                  var needRestart = false;
                  model.allConfig.forEach((element) async {
                    if (element.state == 2) {
                      int result = await DBController.instance
                          .insertStyleFileConfig(element);
                      // logt(TAG, "${element.configPath!}insert $result");
                    } else if (element.state == -1) {
                      int result = await DBController.instance
                          .removeStyleFileConfig(element.id!);
                      // logt(TAG, "${element.configPath!}removed $result");
                    }
                  });
                  Navigator.pop(context, needRestart);
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
                        onChanged: null),
                    RadioListTile<StorageType>(
                        title: Text('公共(其他应用不可见，方便移动文件)'),
                        value: StorageType.Hide,
                        groupValue: value,
                        onChanged: null),
                    child!,
                    RadioListTile<StorageType>(
                        title: Text('应用私有(应用卸载即删除)'),
                        value: StorageType.Private,
                        groupValue: value,
                        onChanged: onRadioChanged),
                  ],
                );
              },
              child: Selector<CreateWSModel, bool>(
                selector: (_, model) =>
                    model.storageType != StorageType.Hide ||
                    model.noMediaFileExist,
                builder: (context, value, child) {
                  return Offstage(
                    offstage: value,
                    child: Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.all(4),
                      child: Text(".nomedia 文件创建失败，请您通过其他文件管理器手动创建"),
                    ),
                  );
                },
              ),
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
                          model.updateStyleResType(value);
                        }),
                    RadioListTile<StyleResType>(
                        title: Text('公共Styles'),
                        value: StyleResType.public,
                        groupValue: value,
                        onChanged: (value) {
                          //todo 选择工作空间
                          model.updateStyleResType(
                            value,
                          );
                        }),
                    Offstage(
                        offstage: value != StyleResType.public, child: child!),
                  ],
                );
              },
              child: getPublicStyles(context, widget.publicStyleConfigs),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> optionsDataFrom(BuildContext context, String styleConfigPath) {
    List<Widget> widgets = [];
    widgets.add(bottomSheetItem("复制远端配置", () async {
      File file = await saveRemoteStylesToLocalFile(styleConfigPath);
      Navigator.pop(context, file);
    }));
    // if (widget.otherWorkspaces != null && widget.otherWorkspaces!.length > 0) {
    //   for (Workspace item in widget.otherWorkspaces!) {
    //     widgets.add(bottomSheetItem("复制远端配置", () async {
    //       Navigator.pop(context);
    //     }));
    //   }
    // }
    return widgets;
  }

  void onRadioChanged(StorageType? value) {
    // logt(TAG, value.toString());
    if (widget.workspace == null) {
      pathController.text = getStoragePath(value, controller.text);
    } else {}
    model.updateStorageType(value!);
  }

  Widget getPublicStyles(
      BuildContext context, List<FileSystemEntity>? publicStyles) {
    // List<PromptStyleFileConfig>? data = snapshot.data!
    //     .map((e) => PromptStyleFileConfig.fromJson(e))
    //     .toList();

    if (null != publicStyles && publicStyles.isNotEmpty) {
      model.allConfig = publicStyles
          .map((e) => PromptStyleFileConfig(configPath: e.path))
          .toList();
      return Column(
        children: generateItems(model.allConfig),
      );
    }
    return Column();
  }

  generateItems(List<PromptStyleFileConfig> allConfig) {
    List<Widget> all = [];
    for (int i = 0; i < allConfig.length; i++) {
      PromptStyleFileConfig e = allConfig[i];
      all.add(ListTile(
        leading: Selector<CreateWSModel, int>(
          selector: (_, model) => model.allConfig[i].state,
          shouldRebuild: (pre, next) {
            bool hasChange = pre != next;
            // logt(TAG, "change notified$hasChange");
            return hasChange;
          },
          builder: (context, state, child) {
            bool checked = state >= 1;
            // logt(TAG, "checkbox rebuild$checked");
            return Checkbox(
              value: checked,
              onChanged: (bool? value) {
                model.updateConfig(i, value!);
              },
            );
          },
        ),
        // 需要重写泛型类的 == 方法
        title: Text(e.getName()),
        subtitle: Text(e.configPath ?? ""),
      ));
    }
    return all;
  }

  @override
  void activate() {
    logt(TAG, "activate");
  }

  @override
  void dispose() {
    super.dispose();
    logt(TAG, "dispose");
  }

  @override
  void didChangeDependencies() {
    logt(TAG, "didChangeDependencies");
  }
}
