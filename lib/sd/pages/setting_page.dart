import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../android.dart';
import '../bean/db/Workspace.dart';
import '../config.dart';
import '../db_controler.dart';
import '../file_util.dart';
import '../http_service.dart';
import '../model/AIPainterModel.dart';
import '../ui_util.dart';

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

  @override
  void initState() {
    super.initState();
    createDirIfNotExit(ANDROID_PUBLIC_STYLES_PATH);
    publicStyleConfigs = Directory(ANDROID_PUBLIC_STYLES_PATH).listSync();
    logt("$ANDROID_PUBLIC_STYLES_PATH", publicStyleConfigs!.length.toString());
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
                          SharedPreferences sp =
                              await SharedPreferences.getInstance();

                          sp.setString(SP_HOST, hostController.text);
                          sdHost = hostController.text;
                          showRestartDialog(context);
                        } else {
                          Fluttertoast.showToast(
                              msg:
                                  AppLocalizations.of(context).networkNotChanged);
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
                Text(
                  AppLocalizations.of(context).styleConfig,
                  style: settingTitle,
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    editOrCreatePromptStyle(context);
                  },
                )
              ],
            ),
            getPublicStyles(context, publicStyleConfigs),
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

      dynamic ws = await Navigator.pushNamed(context, ROUTE_CREATE_WORKSPACE,
          arguments: {
            "applicationPath": applicationPath,
            // "publicPath": publicPath,
            // "openHidePath": openHidePath,
            "workspace": workspace
          }) as Workspace?;

      if (ws is Workspace && ws != null) {
        SharedPreferences sp = await SharedPreferences.getInstance();
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

  Future<void> editOrCreatePromptStyle(BuildContext context,
      {FileSystemEntity? style}) async {
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

      File? file = await Navigator.pushNamed(context, ROUTE_CREATE_STYLE,
          arguments: {"style": style, "files": publicStyleConfigs}) as File?;
      if (null != file) {
        setState(() {
          publicStyleConfigs?.add(file);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget getPublicStyles(
      BuildContext context, List<FileSystemEntity>? publicStyles) {
    // List<PromptStyleFileConfig>? data = snapshot.data!
    //     .map((e) => PromptStyleFileConfig.fromJson(e))
    //     .toList();
    if (null != publicStyles && publicStyles!.isNotEmpty) {
      return Column(
        children: publicStyles.map((e) {
          String fileName = e.path.substring(e.path.lastIndexOf("/"));
          return ListTile(
            // 需要重写泛型类的 == 方法
            title: Text(fileName),
            subtitle: Text(e.path),
            trailing: InkWell(
              onTap: () => editOrCreatePromptStyle(context, style: e),
              child: Icon(Icons.edit),
            ),
          );
        }).toList(),
      );
    }

    return Column();
  }
}
