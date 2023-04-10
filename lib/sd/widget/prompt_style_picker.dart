import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/model/AIPainterModel.dart';

import '../bean/PostPredictResult.dart';
import '../config.dart';
import '../http_service.dart';
import '../mocker.dart';

class PromptStylePicker extends StatelessWidget {
  PromptStylePicker();

  String getStylePrompt() {
    String prompt = "";
    for (var style in provider.styles) {
      if (provider.checkedStyles.contains(style.name)) {
        prompt += appendCommaIfNotExist(style.prompt);
      }
    }
    return prompt;
  }

  String getStyleNegPrompt() {
    String prompt = "";
    for (var style in provider.styles) {
      if (provider.checkedStyles.contains(style.name)) {
        prompt += appendCommaIfNotExist(style.negativePrompt);
      }
    }
    return prompt;
  }

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context);

    return Row(children: [
      Expanded(
        child: Wrap(
          spacing: 8,
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          children: provider.checkedStyles
              .map((e) => RawChip(
                    label: Text(e),
                    deleteIcon: Icon(Icons.delete),
                    onDeleted: () {
                      provider.unCheckStyles(e);
                    },
                  ))
              .toList(),
        ),
      ),
      Column(
        children: [
          InkWell(
            child: const SizedBox(
                width: 36, height: 36, child: Icon(Icons.add_box_outlined)),
            onTap: () {
              showStyleDialog(context);
            },
          ),
          Selector<AIPainterModel, String?>(
            selector: (_, model) => model.selectWorkspace?.stylesConfigFilePath,
            builder: (context, configPath, child) {
              return Offstage(
                offstage: null != configPath && configPath.isNotEmpty,
                child: InkWell(
                  child: const SizedBox(
                      width: 36, height: 36, child: Icon(Icons.refresh)),
                  onTap: () => refreshStyles(),
                ),
              );
            },
          ),
        ],
      )
    ]);
  }

  Future<void> showStyleDialog(BuildContext context) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          AIPainterModel provider = Provider.of<AIPainterModel>(context);
          return AlertDialog(
            title: Text('chose prompt styles'),
            content: SingleChildScrollView(
              child: Wrap(
                children: provider.styles
                    .map((e) => RawChip(
                          label: Text(e.name),
                          selected: provider.checkedStyles.contains(e.name),
                          onSelected: (bool selected) {
                            provider.switchChecked(e.name);
                            // e.checked = selected;
                          },
                          // deleteIcon: Icon(Icons.delete),
                          // onDeleted: () {},
                          // showCheckmark: true,
                        ))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, "cancel");
                  },
                  child: Text("取消")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, "");
                  },
                  child: Text("确定")),
            ],
          );
        });
  }

  refreshStyles() {
    post("$sdHttpService$RUN_PREDICT",
        formData: {"fn_index": CMD_REFRESH_STYLE}, exceptionCallback: (e) {
      Fluttertoast.showToast(msg: "保存失败");
    }).then((value) {
      var result = RunPredictResult.fromJson(value?.data).data[0].choices;
      if (null != result && result.length > 0) {
        provider.refreshStyles(result);
      }
      // if () {
      //   Navigator.pop(context, 1);
      //   Fluttertoast.showToast(msg: '保存成功');
      // }
    });
  }
}
