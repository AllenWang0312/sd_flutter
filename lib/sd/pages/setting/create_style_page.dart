import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/third_util.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/common/util/ui_util.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import '../../../common/ui_util.dart';
import '../../bean/PromptStyle.dart';
import '../../bean/enum/CreateStyleType.dart';
import '../../const/config.dart';
import '../../http_service.dart';
import 'CreateStyleModel.dart';

Future<File> saveRemoteStylesToLocalFile(String styleConfigPath) {
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
    if (createFileIfNotExit(f)) {
      logt(TAG, "style file create success $styleConfigPath");
      List re = value?.data as List;
      // provider.styles = re.map((e) => PromptStyle.fromJson(e)).toList();
      // 生成csv文件，csv文件路径：缓存目录下的 ble文件夹下
      try {
        String csv =
            const ListToCsvConverter().convert(PromptStyle.convertDynamic(re));
        return await f.writeAsString(csv);
      } catch (e) {
        logt(TAG, e.toString());
      }
    }
  });
  return Future.error('');
}

final String TAG = "CreateStyleWidget";

class CreateStyleWidget extends StatelessWidget {

  late bool _existPublicStylesFiles;
  List<FileSystemEntity> publicStylesFiles; // todo 从上个页面传过来
  FileSystemEntity? style;
  String autoSaveAbsPath;

  CreateStyleWidget(this.style, this.autoSaveAbsPath, this.publicStylesFiles) {
    _existPublicStylesFiles = publicStylesFiles.isNotEmpty;
  }

  late CreateStyleModel model;

  late TextEditingController controller;
  late TextEditingController pathController;
  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    model = Provider.of<CreateStyleModel>(context, listen: false);
    provider = Provider.of<AIPainterModel>(context, listen: false);

    controller = TextEditingController(text: '');
    pathController = TextEditingController(text: '');
    controller.addListener(() {
      model.updateFileName(controller.text);
      pathController.text = "$autoSaveAbsPath/${controller.text}.csv";
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('创建style'),
        actions: [
          IconButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  if (model.resType == CreateStyleType.copyFromRemote) {
                    if (await checkStoragePermission()) {
                      dynamic file = await saveRemoteStylesToLocalFile(
                          pathController.text);
                      Navigator.pop(context, file);
                    }
                  } else if (model.resType == CreateStyleType.empty) {
                    File file = File(pathController.text);
                    createFileIfNotExit(file);
                    Navigator.pop(context, file);
                  } else if (model.resType == CreateStyleType.spliteOther) {
                    await File(model.splitFile).writeAsString(
                        const ListToCsvConverter().convert(
                            PromptStyle.convertPromptStyle(model.current
                                .where((element) => !element.checked)
                                .toList())));

                    File file = File(pathController.text);
                    createFileIfNotExit(file);
                    List<PromptStyle> styles = model.current
                        .where((element) => element.checked)
                        .toList();
                    String csv = const ListToCsvConverter()
                        .convert(PromptStyle.convertPromptStyle(styles));
                    await file.writeAsString(csv);

                    Navigator.pop(context, file);
                  }
                } else {
                  Fluttertoast.showToast(msg: "请输入风格（Style）名",gravity: ToastGravity.CENTER);
                }
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('名称'),
          TextField(
            controller: controller,
          ),
          Text('存储路径'),
          // Selector<CreateStyleModel, StorageType?>(
          //   selector: (_, model) => model.storageType,
          //   builder: (context, value, child) {
          //     return Column(
          //       children: [
          //         RadioListTile<StorageType>(
          //             title: Text('公共(系统可见)'),
          //             value: StorageType.Public,
          //             groupValue: value,
          //             onChanged: onRadioChanged),
          //         RadioListTile<StorageType>(
          //             title: Text('应用私有(应用卸载即删除)'),
          //             value: StorageType.Private,
          //             groupValue: value,
          //             onChanged: onRadioChanged),
          //       ],
          //     );
          //   },
          // ),
          TextField(
            controller: pathController,
          ),
          Text("如何初始化"),
          Selector<CreateStyleModel, CreateStyleType?>(
              selector: (_, model) => model.resType,
              builder: (context, value, child) {
                return Column(
                  children: [
                    RadioListTile<CreateStyleType>(
                        title: Text('新建文件，并复制远端配置'),
                        value: CreateStyleType.copyFromRemote,
                        groupValue: value,
                        onChanged: updateCreateStyleType),
                    RadioListTile<CreateStyleType>(
                        title: Text('仅新建文件，不填充数据'),
                        value: CreateStyleType.empty,
                        groupValue: value,
                        onChanged: updateCreateStyleType),
                    RadioListTile<CreateStyleType>(
                        title: Text('拆分现有styles'),
                        value: CreateStyleType.spliteOther,
                        groupValue: value,
                        onChanged: updateCreateStyleType),
                  ],
                );
              }),
          Selector<CreateStyleModel, CreateStyleType?>(
            selector: (_, model) => model.resType,
            builder: (context, value, child) {
              return Offstage(
                offstage: !(_existPublicStylesFiles &&
                    value == CreateStyleType.spliteOther),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton(
                        // hint: Text(selectedUpScale != null
                        //     ? "${selectedUpScale!.name}"
                        //     : "请选择模型"),
                        items: getFileItems(publicStylesFiles),
                        onChanged: (newValue) async {
                          if (newValue is FileSystemEntity) {
                            logt(TAG, "updateCurrent" + newValue.path);
                            model.upDateCurrent(
                                newValue.path,
                                await loadPromptStyleFromCSVFile(
                                    newValue.path,provider.userInfo.age));
                          }
                        }),
                    Text("->"),
                    child!
                  ],
                ),
              );
            },
            child: Selector<CreateStyleModel, String>(
                selector: (_, model) => model.newFileName,
                builder: (context, value, child) {
                  return Text(value);
                }),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, cons) {
                double widht = cons.maxWidth;
                double height = cons.maxHeight;
                return Selector<CreateStyleModel, List<PromptStyle>?>(
                  selector: (_, model) => model.current,
                  builder: (context, list, child) {
                    return Offstage(
                      offstage: list!.isEmpty,
                      child: Row(
                        children: [
                          SizedBox(
                            height: height,
                            width: widht / 2,
                            child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Selector<CreateStyleModel, bool>(
                                        selector: (_, model) =>
                                            model.current[index].checked,
                                        builder: (context, value, child) {
                                          return Checkbox(
                                              value: value,
                                              onChanged: (value) {
                                                model.updateCheckState(
                                                    index, value!);
                                              });

                                          //   Row(
                                          //   children: [
                                          //     Text(value.name),
                                          //     Text(value.prompt),
                                          //     Text(value.prompt),
                                          //   ],
                                          // );
                                        },
                                      ),
                                      Text(list![index].name)
                                    ],
                                  );
                                }),
                          ),
                          SizedBox(
                            width: widht / 6,
                            child: Text("=>"),
                          ),
                          Selector<CreateStyleModel, String>(
                            selector: (_, model) => model.getCheckStyles(),
                            builder: (context, str, child) {
                              logt(TAG, "split list changed");
                              return SizedBox(
                                width: widht / 3,
                                height: height,
                                child: Text(str),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  List<Widget> optionsDataFrom(BuildContext context, String styleConfigPath) {
    List<Widget> widgets = [];
    widgets.add(bottomSheetItem("复制远端配置", () async {
      get("$sdHttpService$GET_STYLES", exceptionCallback: (e) {
        Fluttertoast.showToast(msg: "请求失败：${e.toString()}");
      }).then((value) async {
        File f = File(styleConfigPath);

        if (!f.existsSync()) {
          File(styleConfigPath).createSync(recursive: true, exclusive: true);
        }
        if (f.existsSync()) {
          List re = value?.data as List;
          // provider.styles = re.map((e) => PromptStyle.fromJson(e)).toList();
          // 生成csv文件，csv文件路径：缓存目录下的 ble文件夹下
          try {
            String csv = const ListToCsvConverter()
                .convert(PromptStyle.convertDynamic(re));
            File csvFile = await f.writeAsString(csv);
            Navigator.pop(context, csvFile);
          } catch (e) {}
        }
      });
      // Navigator.pop(context);
    }));
    return widgets;
  }

  void updateCreateStyleType(CreateStyleType? value) {
    model.updateCreateStyleType(value);
  }
}
