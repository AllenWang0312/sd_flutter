import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../../common/util/string_util.dart';

class PromptStylePicker extends StatelessWidget {
  PromptStylePicker();

  String getStylePrompt() {
    String prompt = "";
    String mainPrompt = "";
    String detailPrompt = "";
    for (PromptStyle style in provider.styles) {
      if (provider.txt2img.checkedStyles.contains(style.name)) {
        if (style.step == 0) {
          prompt += appendCommaIfNotExist(style.prompt ?? "");
        } else if (style.step == 1) {
          mainPrompt += appendCommaIfNotExist(style.prompt ?? "");
        } else {
          detailPrompt += appendCommaIfNotExist(style.prompt ?? "");
        }
      }
    }
    return mainPrompt.isEmpty
        ? prompt
        : "$prompt(($mainPrompt)|($detailPrompt))";
  }

  String getStyleNegPrompt() {
    String prompt = "";
    for (PromptStyle style in provider.styles) {
      if (provider.txt2img.checkedStyles.contains(style.name)) {
        prompt += appendCommaIfNotExist(style.negativePrompt ?? "");
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
          children: provider.txt2img.checkedStyles
              .map((e) => RawChip(
                    label: Text(e),
                    onDeleted: () {
                      provider.unCheckStyles(e);
                    },
                  ))
              .toList(),
        ),
      ),
      Column(
        children: [
          IconButton(
              onPressed: () => showStyleDialog(context),
              icon: Icon(Icons.add_box_outlined)),
          Selector<AIPainterModel, bool>(
            selector: (_, model) => model.txt2img.checkedStyles.isEmpty,
            builder: (_, newValue, child) {
              return Offstage(
                offstage: newValue,
                child: IconButton(
                    onPressed: () {
                      provider.cleanCheckedStyles();
                    },
                    icon: const Icon(Icons.delete)),
              );
            },
          ),

          // Selector<AIPainterModel, List<PromptStyleFileConfig>?>(
          //   selector: (_, model) => model.selectWorkspace?.styleConfigs,
          //   shouldRebuild: (pre,next)=>pre?.length!=next?.length,
          //   builder: (context, list, child) {
          //     return Offstage(
          //       offstage: !list!.contains(''),
          //       child: InkWell(
          //         child: const SizedBox(
          //             width: 36, height: 36, child: Icon(Icons.refresh)),
          //         onTap: () => refreshStyles(context),
          //       ),
          //     );
          //   },
          // ),
        ],
      )
    ]);
  }

  Future<void> showStyleDialog(BuildContext context) async {
    if (null != provider.publicStyles) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            AIPainterModel provider = Provider.of<AIPainterModel>(context);
            return SingleChildScrollView(
              child: provider.promptType == 3
                  ? provider.optional.generate(provider)
                  : generateStyles(provider.publicStyles!),
            );
            // return AlertDialog(
            //   title: Text(AppLocalizations.of(context).choseStyles),
            //   content:,
            //   actions: [
            //     TextButton(
            //         onPressed: () {
            //           Navigator.pop(context, "cancel");
            //         },
            //         child: Text(AppLocalizations.of(context).cancel)),
            //     TextButton(
            //         onPressed: () {
            //           Navigator.pop(context, "");
            //         },
            //         child: Text(AppLocalizations.of(context).ok)),
            //   ],
            // );
          });
    }
  }

  // refreshStyles(BuildContext context) {
  //   post("$sdHttpService$RUN_PREDICT",
  //       formData: {"fn_index": CMD_REFRESH_STYLE}, exceptionCallback: (e) {
  //     Fluttertoast.showToast(msg: AppLocalizations.of(context).saveFailed);
  //   }).then((value) {
  //     var result = RunPredictResult.fromJson(value?.data).data[0].choices;
  //     if (null != result && result.length > 0) {
  //       provider.refreshStyles(result);
  //     }
  //     // if () {
  //     //   Navigator.pop(context, 1);
  //     //   Fluttertoast.showToast(msg: '保存成功');
  //     // }
  //   });
  // }

  Widget generateStyles(Map<String, List<PromptStyle>?> map) {
    List<Widget> result = [];
    for (String key in map.keys) {
      List<PromptStyle>? value = map[key];
      if (value != null && value.isNotEmpty) {
        result.add(Text(key));
        result.add(Wrap(
          children: value
              .map((e) => RawChip(
                    label: Text(e.name),
                    selected: provider.txt2img.checkedStyles.contains(e.name),
                    onSelected: (bool selected) {
                      provider.switchChecked(e.name);
                      // e.checked = selected;
                    },
                    // deleteIcon: Icon(Icons.delete),
                    // onDeleted: () {},
                    // showCheckmark: true,
                  ))
              .toList(),
        ));
      }
    }
    return Column(
      children: result,
    );
  }
}
