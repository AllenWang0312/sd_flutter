import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/db/PromptStyleFileConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bean/db/Workspace.dart';
import '../config.dart';
import '../db_controler.dart';
import '../../common/util/file_util.dart';
import '../http_service.dart';
import '../model/AIPainterModel.dart';
import '../../common/util/ui_util.dart';

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
  @override
  void initState() {
    createDir();
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context);
    TextEditingController hostController = TextEditingController(text: sdHost);

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
            child: Text("立即重启"),
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
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  const Text("  http;//"),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextField(
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        controller: hostController,
                      ),
                    ),
                  ),
                  const Text(":$SD_PORT"),
                  TextButton(
                      onPressed: () async {
                        if (hostController.text != sdHost) {
                          sp.setString(SP_HOST, hostController.text);
                          sdHost = hostController.text;
                          showRestartDialog(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: AppLocalizations.of(context)
                                  .networkNotChanged,gravity: ToastGravity.CENTER);
                        }
                      },
                      child: Text(AppLocalizations.of(context).save))
                ],
              ),
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
                            sp.setBool(SP_AUTO_SAVE,value);
                            Provider.of<AIPainterModel>(context, listen: false)
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
                            sp.setBool(SP_HIDE_NSFW,value);
                            Provider.of<AIPainterModel>(context, listen: false)
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
                            sp.setBool(SP_CHECK_IDENTITY,value);
                            Provider.of<AIPainterModel>(context, listen: false)
                                .updateHideNSFW(value);
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
                  icon: Icon(Icons.add),
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
                    if (datas.length > 0) {
                      workspaces =
                          datas.map((e) => Workspace.fromJson(e)).toList();

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
    workspaces = result?.map((e) => Workspace.fromJson(e)).toList();
  }

  Future<void> editOrCreateWorkspace(BuildContext context,
      {int? type = 0, Workspace? workspace}) async {
    try {
      var applicationPath = await getImageAutoSaveAbsPath();
      var stylePath = await getStylesAbsPath();
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
            .map((e) => PromptStyleFileConfig.fromJson(e, state: 1))
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
    var applicationPath = await getStylesAbsPath();

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
                            title: Text("确认删除"),
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
                    onTap: () => editPromptStyle(context, e),
                    child: Icon(Icons.edit),
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

    var publicStylePath = await getStylesAbsPath();
    if (createDirIfNotExit(publicStylePath)) {
      return Directory(publicStylePath).listSync();
    }
    return null;
  }

  editPromptStyle(BuildContext context, FileSystemEntity e) {
    Navigator.pushNamed(context, ROUTE_EDIT_STYLE, arguments: e.path);
  }

  Future<void> init() async {
    sp = await SharedPreferences.getInstance();
  }
}
