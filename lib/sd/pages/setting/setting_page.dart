import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/common/util/ui_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/db/PromptStyleFileConfig.dart';
import 'package:sd/sd/bean/db/Workspace.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/const/sp_key.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'IPConfigWidget.dart';

final String TAG = "SettingPage";

class SettingPage extends StatefulWidget {
  SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<FileSystemEntity>? publicStyleConfigs;

  List<Workspace>? workspaces;

  late AIPainterModel provider;

  TextStyle settingTitle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  late SharedPreferences sp;
  late IPConfigWidget ipConfigWidget;

  @override
  void initState() {
    createDir();
    init();
    super.initState();
  }

  // ServiceNetLocation value = ServiceNetLocation.private;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context,listen: false);
    ipConfigWidget = IPConfigWidget(sdShare);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          AppLocalizations.of(context).setting,
        ),
        actions: [
          TextButton(
            onPressed: () {
              showRestartNowDialog(context);
            },
            child: const Text("立即重启"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).networkAddress,
              style: settingTitle,
            ),
            //https://d17eae44-da1d-413c.gradio.live
            ipConfigWidget,
            Text('接口优先级'),
            Selector<AIPainterModel, int>(
              selector: (_, model) => model.generateType,
              builder: (_, newValue, child) {
                return Column(
                  children: [
                    RadioListTile<int>(
                        title: Text('api 优先(返回原始数据,可以保存图片在端侧)'),
                        value: 0,
                        toggleable: true,
                        groupValue: newValue,
                        onChanged: _switchGenerateType),
                    RadioListTile<int>(
                        title: Text('predict 优先(返回远端文件路径,设置plugin封面依赖此方法)'),
                        value: 1,
                        toggleable: true,
                        groupValue: newValue,
                        onChanged: _switchGenerateType),
                  ],
                );
              },
            ),
            // Text('prompt 主次执行'),
            // Selector<AIPainterModel, int>(
            //     selector: (_, model) => model.promptType,
            //     shouldRebuild: (pre, next) => pre != next,
            //     builder: (_, newValue, child) {
            //       return Column(
            //         children: [
            //           RadioListTile<int>(
            //               value: 2,
            //               title: const Text('根据配置'),
            //               toggleable: true,
            //               groupValue: newValue,
            //               onChanged: _switchPromptType),
            //           RadioListTile<int>(
            //               value: 3,
            //               title: const Text('内部分类'),
            //               toggleable: true,
            //               groupValue: newValue,
            //               onChanged: _switchPromptType),
            //         ],
            //       );
            //     }),
            Selector<AIPainterModel, int>(
                selector: (_, model) => model.styleFrom,
                shouldRebuild: (pre, next) => pre != next,
                builder: (_, newValue, child) {
                  return SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'prompt 主次执行',
                          style: settingTitle,
                        ),
                        CupertinoSwitch(
                            value: newValue == 3,
                            onChanged: (value) {
                              _switchPromptType(value ? 3 : 1);
                            })
                      ],
                    ),
                  );
                }),
            Selector<AIPainterModel, bool>(
              selector: (_, model) => model.autoGenerate,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, newValue, child) {
                return Container(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "自动重试",
                      ),
                      CupertinoSwitch(
                          value: newValue,
                          onChanged: (value) {
                            sp.setBool(SP_AUTO_GENERATE, value);
                            provider
                                .updateAutoGenerate(value);
                          })
                    ],
                  ),
                );
              },
            ),
            Selector<AIPainterModel, bool>(
              selector: (_, model) => model.autoSave,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, newValue, child) {
                return Container(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).autoSave,
                        style: settingTitle,
                      ),
                      CupertinoSwitch(
                          value: newValue,
                          onChanged: (value) {
                            sp.setBool(SP_AUTO_SAVE, value);
                            provider
                                .updateAutoSave(value);
                          })
                    ],
                  ),
                );
              },
            ),
            Selector<AIPainterModel, bool>(
              selector: (_, model) => model.hideNSFW,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, newValue, child) {
                return Container(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).hideNSFW,
                        style: settingTitle,
                      ),
                      CupertinoSwitch(
                          value: newValue,
                          onChanged: (value) {
                            sp.setBool(SP_HIDE_NSFW, value);
                            provider
                                .updateHideNSFW(value);
                          })
                    ],
                  ),
                );
              },
            ),
            Selector<AIPainterModel, bool>(
              selector: (_, model) => model.checkIdentityWhenReEnter,
              shouldRebuild: (pre, next) => pre != next,
              builder: (_, newValue, child) {
                return Container(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).checkIdentity,
                        style: settingTitle,
                      ),
                      CupertinoSwitch(
                          value: newValue,
                          onChanged: (value) {
                            sp.setBool(SP_CHECK_IDENTITY, value);
                            provider
                                .updateCheckIdentity(value);
                          })
                    ],
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).workspace,
                  style: settingTitle,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    editOrCreateWorkspace(context);
                  },
                )
              ],
            ),
            FutureBuilder(
                future: DBController.instance.queryWorkspaces(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List datas = snapshot.data as List;
                    logt(TAG, 'ws count ${datas.length}');
                    if (datas.isNotEmpty) {
                      workspaces = datas
                          .map((e) =>
                              Workspace.fromJson(e, asyncPath + WORKSPACES))
                          .toList();

                      return Column(
                        children: workspaces!
                            .map((e) => Selector<AIPainterModel, Workspace?>(
                                  selector: (_, model) => model.selectWorkspace,
                                  builder: (context, selected, child) {
                                    return RadioListTile<Workspace>(
                                        // 需要重写泛型类的 == 方法
                                        value: e,
                                        title: Text(e.getName()),
                                        subtitle: child,
                                        secondary: InkWell(
                                          onTap: () => editOrCreateWorkspace(
                                              context,
                                              type: e.pathType,
                                              workspace: e),
                                          child: const Icon(Icons.edit),
                                        ),
                                        groupValue: selected,
                                        onChanged: (value) {
                                          logt(TAG, value.toString());
                                          provider
                                              .updateSelectWorkspace(value!);
                                          showRestartDialog(context);
                                        });
                                  },
                                  child: Text(e.getDesc()),
                                ))
                            .toList(),
                      );
                    }
                  }
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.red,
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).styleConfig,
                  style: settingTitle,
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    createPromptStyle(context);
                  },
                )
              ],
            ),
            getPublicStyles(context),
          ],
        ),
      ),
    );
  }

  Future<void> loadWorkSpacesFromDB() async {
    List? result = await DBController.instance.queryWorkspaces();
    workspaces = result
        ?.map((e) => Workspace.fromJson(e, asyncPath + WORKSPACES))
        .toList();
  }

  Future<void> editOrCreateWorkspace(BuildContext context,
      {int? type = 0, Workspace? workspace}) async {
    try {
      var applicationPath = getWorkspacesPath();
      var stylePath = getStylesPath();
      // var publicPath = getAutoSaveAbsPath();
      // var openHidePath = "$publicPath/nomedia";
      // logt(TAG, applicationPath + publicPath + openHidePath);

      // if (!await Directory(publicPath).exists()) {
      //   Directory(publicPath).createSync(recursive: true);
      // if (UniversalPlatform.isAndroid&&!await File(openHidePath + "/.nomedia").exists()) {
      //   await File(openHidePath + "/.nomedia").create();
      // }
      // }
      List<PromptStyleFileConfig>? wsStyleConfigs;

      if (null != workspace) {
        logt(TAG, "ws not null" + workspace.toString());

        var map = await DBController.instance.queryStyles(workspace.id!);
        wsStyleConfigs = map!
            .map((e) =>
                PromptStyleFileConfig.fromJson(e, getStylesPath(), state: 1))
            .toList();
      }
      logt(TAG, wsStyleConfigs.toString() ?? "null");
      dynamic ws = await Navigator.pushNamed(context, ROUTE_CREATE_WORKSPACE,
          arguments: {
            "imgSavePath": applicationPath,
            "styleSavePath": stylePath,
            // "publicPath": publicPath,
            // "openHidePath": openHidePath,
            "workspace": workspace,
            "configs": wsStyleConfigs,
            "publicStyleConfigs": publicStyleConfigs
          }) as Workspace?;

      if (ws is Workspace && ws != null) {
        sp.setString(SP_CURRENT_WS, ws.name);
        showRestartDialog(context);
      } else if (ws is bool && ws) {
        showRestartDialog(context);
      }
      // showDialog(
      //     context: context,
      //     builder: (_) {
      //       return ChangeNotifierProvider(
      //           create: (_) => CreateWSModel(),
      //           child: CreateWorkspaceWidget(
      //               applicationPath, publicPath, openHidePath,
      //               type: type, workspace: workspace));
      //     });
    } catch (e) {
      print(e);
    }
  }

  Future<void> createPromptStyle(BuildContext context) async {
    var applicationPath = await getStylesPath();

    if (context.mounted) {
      File? file = await Navigator.pushNamed(context, ROUTE_CREATE_STYLE,
          arguments: {
            "autoSaveAbsPath": applicationPath,
            "files": publicStyleConfigs
          }) as File?;
      if (null != file) {
        setState(() {
          publicStyleConfigs?.add(file);
        });
      }
    }
  }

  Widget getPublicStyles(BuildContext context) {
    // List<PromptStyleFileConfig>? data = snapshot.data!
    //     .map((e) => PromptStyleFileConfig.fromJson(e))
    //     .toList();
    return FutureBuilder(
      future: createDir(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          publicStyleConfigs = snapshot.data;
          return Column(
            children: publicStyleConfigs!.map((e) {
              String fileName = e.path.substring(e.path.lastIndexOf("/"));
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text("确认删除"),
                            content: Text("点击确认删除文件${e.path}"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    File(e.path).delete(recursive: true);
                                    setState(() {
                                      publicStyleConfigs!.remove(e);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('确认'))
                            ],
                          ));
                },
                child: ListTile(
                  // 需要重写泛型类的 == 方法
                  title: Text(fileName),
                  subtitle: Text(e.path),
                  trailing: InkWell(
                    onTap: () => editPromptStyle(
                      context,
                      e,
                    ),
                    child: const Icon(Icons.edit),
                  ),
                ),
              );
            }).toList(),
          );
        }

        return Column();
      },
    );
  }

  Future<List<FileSystemEntity>?> createDir() async {
    var publicStylePath = await getStylesPath();
    if (createDirIfNotExit(publicStylePath)) {
      return Directory(publicStylePath).listSync();
    }
    return null;
  }

  editPromptStyle(BuildContext context, FileSystemEntity e) {
    Navigator.pushNamed(context, ROUTE_EDIT_STYLE,
        arguments: {"filePath": e.path, "userAge": provider.userInfo.age});
  }

  Future<void> init() async {
    sp = await SharedPreferences.getInstance();
  }

  void _switchPromptType(int? type) {
    logt(TAG, type?.toString() ?? 'null');
    if (null != type) {
      provider.updatePromptType(type);
      sp.setInt(SP_PROMPT_TYPE, type);
    }
  }

  void _switchGenerateType(int? type) {
    logt(TAG, type?.toString() ?? 'null');
    if (null != type) {
      provider.updateGenerateType(type);
      sp.setInt(SP_GENERATE_TYPE, type);
    }
  }
}
