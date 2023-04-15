import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/db/PromptStyleFileConfig.dart';
import 'package:sd/sd/config.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/model/AIPainterModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../android.dart';
import '../bean/db/Workspace.dart';
import '../file_util.dart';
import '../http_service.dart';
import '../ui_util.dart';

final String TAG = "SettingPage";

class SettingPage extends StatelessWidget {
  List<Workspace>? workspaces;

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context);
    TextEditingController hostController = TextEditingController(text: sdHost);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Setting'),
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            child: Row(
              children: [
                const Text("服务地址  http;//"),
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
                Text(":$SD_PORT"),
                TextButton(
                    onPressed: () async {
                      if (hostController.text != sdHost) {
                        SharedPreferences sp =
                            await SharedPreferences.getInstance();

                        sp.setString(SP_HOST, hostController.text);
                        sdHost = hostController.text;
                        showRestartDialog(context);
                      } else {
                        Fluttertoast.showToast(msg: '地址未改动');
                      }
                    },
                    child: Text("保存"))
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
                    Text("自动保存"),
                    CupertinoSwitch(
                        value: newValue,
                        onChanged: (value) {
                          Provider.of<AIPainterModel>(context, listen: false)
                              .updateAutoSave(value);
                        })
                  ],
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("工作空间"),
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
                                        child: Icon(Icons.edit),
                                      ),
                                      groupValue: selected,
                                      onChanged: (value) {
                                        logt(TAG, value.toString());
                                        provider.updateSelectWorkspace(value!);
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
              Text("style配置"),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  editOrCreatePromptStyle(context, null);
                },
              )
            ],
          ),
          FutureBuilder(
              future: DBController.instance.getStyleFileConfigs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<PromptStyleFileConfig>? data = snapshot.data!
                      .map((e) => PromptStyleFileConfig.fromJson(e))
                      .toList();
                  if (null != data && data.isNotEmpty) {
                    return Column(
                      children: data
                          .map((e) => ListTile(
                                // 需要重写泛型类的 == 方法
                                title: Text(e.name.toString()),
                                subtitle: Text(e.configPath.toString()),
                                trailing: InkWell(
                                  onTap: () =>
                                      editOrCreatePromptStyle(context, e),
                                  child: Icon(Icons.edit),
                                ),
                              ))
                          .toList(),
                    );
                  }
                }
                return Container();
              })
        ],
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
      var applicationPath = await getAutoSaveAbsPath();
      // var publicPath = getAutoSaveAbsPath();
      // var openHidePath = "$publicPath/nomedia";
      // logt(TAG, applicationPath + publicPath + openHidePath);

      // if (!await Directory(publicPath).exists()) {
      //   Directory(publicPath).createSync(recursive: true);
        // if (UniversalPlatform.isAndroid&&!await File(openHidePath + "/.nomedia").exists()) {
        //   await File(openHidePath + "/.nomedia").create();
        // }
      // }

      Workspace? ws = await Navigator.pushNamed(context, ROUTE_CREATE_WORKSPACE,
          arguments: {
            "applicationPath": applicationPath,
            // "publicPath": publicPath,
            // "openHidePath": openHidePath,
            "workspace": workspace
          }) as Workspace?;

      if (ws != null) {
        SharedPreferences sp = await SharedPreferences.getInstance();
        sp.setString(SP_CURRENT_WS, ws.name);
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

  Future<void> editOrCreatePromptStyle(
      BuildContext context, PromptStyleFileConfig? style) async {
    try {
      var applicationPath = await getAutoSaveAbsPath();
      // var publicPath = getPublicPicturesPath();
      // var openHidePath = "$publicPath/nomedia";
      // logt(TAG, applicationPath + publicPath + openHidePath);

      // if (!await Directory(openHidePath).exists()) {
      //   await Directory(openHidePath).create();
      //   if (!await File(openHidePath + "/.nomedia").exists()) {
      //     await File(openHidePath + "/.nomedia").create();
      //   }
      // }

      PromptStyleFileConfig? ws =
          await Navigator.pushNamed(context, ROUTE_CREATE_STYLE, arguments: {
        "applicationPath": applicationPath,
        // "publicPath": publicPath,
        // "openHidePath": openHidePath,
        "style": style
      }) as PromptStyleFileConfig?;
    } catch (e) {
      print(e);
    }
  }
}
