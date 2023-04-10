import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/pages/PathProviderWidget.dart';

import '../bean/PromptStyle.dart';
import '../bean/db/PromptStyleFileConfig.dart';
import '../config.dart';
import '../http_service.dart';
import '../ui_util.dart';

class CreateStyleModel with ChangeNotifier, DiagnosticableTreeMixin {
  StorageType? storageType = StorageType.Public;

  void updateStorageType(StorageType storageType) {
    this.storageType = storageType;
    notifyListeners();
  }
}

final String TAG = "CreateStyleWidget";

class CreateStyleWidget extends PathProviderWidget {
  PromptStyleFileConfig? style;

  CreateStyleWidget(
      String applicationPath, String publicPath, String openHidePath,
      {this.style})
      : super(applicationPath, publicPath, openHidePath);
  late CreateStyleModel model;

  late TextEditingController controller;
  late TextEditingController pathController;

  @override
  Widget build(BuildContext context) {
    model = Provider.of<CreateStyleModel>(context, listen: false);
    controller = TextEditingController(text: style == null ? '' : style?.name);
    pathController =
        TextEditingController(text: style == null ? '' : style?.configPath);
    controller.addListener(() {
      pathController.text = getStoragePath(model.storageType, controller.text);
      // model.updateStyleResType(
      //     model.styleResType, "$applicationPath/${controller.text}/styles.csv");
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(style == null ? '创建style' : '修改style'),
        actions: [IconButton(onPressed: () async {}, icon: Icon(Icons.add))],
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
            Selector<CreateStyleModel, StorageType?>(
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
            Text("数据来源"),
            RadioListTile<StyleResType>(
                title: Text('仅新建文件，不填充数据'),
                value: StyleResType.empty,
                groupValue: resType,
                onChanged: (value) {}),
            RadioListTile<StyleResType>(
                title: Text('从现有styles复制'),
                value: StyleResType.copy,
                groupValue: resType,
                onChanged: (value) {}),
          ],
        ),
      ),
    );
  }

  StyleResType resType = StyleResType.empty;

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
            String csv =
                const ListToCsvConverter().convert(PromptStyle.convert(re));
            File csvFile = await f.writeAsString(csv);
            Navigator.pop(context, csvFile);
          } catch (e) {}
        }
      });
      // Navigator.pop(context);
    }));
    return widgets;
  }

  void onRadioChanged(StorageType? value) {
    if (style == null) {
      pathController.text = getStoragePath(value, controller.text);
    } else {}
    model.updateStorageType(value!);
  }
}
