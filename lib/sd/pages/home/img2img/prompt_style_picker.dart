import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/pages/home/img2img/prompt_widget.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../../common/util/string_util.dart';
import '../../../http_service.dart';

//tag 已选及锁定 状态组件
class SDPromptStylePicker extends StatelessWidget {
  SDPromptStylePicker();

  String getStylePrompt() {
    String prompt = "";
    for (PromptStyle style in provider.styles) {
      if (provider.checkedStyles.contains(style.name)) {
        prompt += appendCommaIfNotExist(style.prompt ?? "");
      }
      if (provider.checkedRadio.contains(style.name)) {
        prompt += appendCommaIfNotExist(style.prompt ?? "");
      }
    }
    return prompt;
  }

  String getStylePromptV3(
      int width, int height, int steps, double bgWeight, double weight) {
    List<String> prompt = List.generate(10, (index) => "");
    for (PromptStyle style in provider.styles) {
      if (provider.checkedStyles.contains(style.name)) {
        if (null != style.prompt && style.prompt!.isNotEmpty) {
          prompt[style.step ?? 0] += appendCommaIfNotExist("{${style.prompt}}");
        }
      }
      if (provider.checkedRadio.contains(style.name)) {
        if (null != style.prompt && style.prompt!.isNotEmpty) {
          prompt[style.step ?? 0] += appendCommaIfNotExist("{${style.prompt}}");
        }
      }
    }

    int bgStep = steps * bgWeight ~/ 10;
    int mainStep = (steps - bgStep) * weight ~/ 10;
    //todo 过长的图用天空填充背景
    if (provider.txt2img.height > provider.txt2img.width * 1.7 ||
        provider.txt2img.width > provider.txt2img.height * 1.5) {
      return "${prompt[0]}"
          "[{beautiful detailed sky,${prompt[1]}}:{"
          "${prompt[9]}${prompt[2]}"
          "[(${prompt[3]}):(${prompt[4]}):$mainStep] "
          "{${prompt[6]}"
          "[(${prompt[7]}):(${prompt[8]}):$mainStep]}${prompt[5]}"
          "}:$bgStep]";
    } else {
      int poseStep = steps * weight ~/ 10;
      return "${prompt[0]}"
          "${sfw ? "SFW," : ""}"
          "${prompt[1]}${prompt[9]}${prompt[2]}"
          "[(${prompt[3]}):(${prompt[4]}):$poseStep]\n"
          "{${prompt[6]}"
          "[(${prompt[7]}):(${prompt[8]}):$poseStep]\n"
          "${prompt[5]}";
    }
  }

  String getStyleNegPrompt() {
    String prompt = sfw ? "NSFW," : "";
    for (PromptStyle style in provider.styles) {
      if (provider.checkedStyles.contains(style.name)) {
        if (null != style.negativePrompt && style.negativePrompt!.isNotEmpty) {
          prompt += appendCommaIfNotExist(style.negativePrompt!);
        }
      }
    }
    return prompt;
  }

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context); //需要监听配置改变
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Wrap(
        spacing: 8,
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        children: ([]
              ..addAll(provider.checkedStyles)
              ..addAll(provider.checkedRadio))
            .map((e) => Selector<AIPainterModel, int>(
                  selector: (_, model) =>
                      model.lockedRadioGroup.length + model.lockedStyles.length,
                  builder: (_, value, child) {
                    return GestureDetector(
                        onTap: () {
                          provider.lockSelector(e);
                        },
                        child: RawChip(
                          avatar: (provider.selectorLocked(e) ||
                                  provider.lockedStyles.contains(e))
                              ? CircleAvatar(
                                  radius: 6,
                                  child: Container(
                                    color: Colors.red,
                                  ),
                                )
                              : null,
                          label: Text(e),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 2),
                          onDeleted: () {
                            provider.unCheckStyles(e);
                            provider.unCheckRadio(e);
                          },
                        ));
                  },
                ))
            .toList(),
      ),
      Selector<AIPainterModel, bool>(
        selector: (_, model) =>
            model.checkedStyles.isEmpty && model.checkedRadio.isEmpty,
        builder: (_, newValue, child) {
          return Offstage(
            offstage: newValue,
            child: Row(
              children: [
                TextButton(onPressed: (){
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                            content:   SDPromptWidget()
                        );
                      });
                }, child: Text("prompt"),),
                Spacer(),
                IconButton(
                    onPressed: () {
                      provider.savePromptsToSP(toast: true);
                    },
                    icon: Icon(Icons.save)),
                IconButton(
                    onPressed: () {
                      provider.cleanCheckedStyles();
                    },
                    icon: const Icon(Icons.delete))
              ],
            ),
          );
        },
      ),
      // Row(
      //   children: [
      // IconButton(
      //     onPressed: () => showStyleDialog(context),
      //     icon: const Icon(Icons.add_box_outlined)),

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
      // ],
      // )
    ]);
  }

  // Future<void> showStyleDialog(BuildContext context) async {
  //   if (null != provider.publicStyles) {
  //     showBottomSheet(
  //         context: context,
  //         builder: (context) {
  //           AIPainterModel provider = Provider.of<AIPainterModel>(context);
  //           return
  //               // provider.promptType == 3
  //               //     ?
  //               // //provider.optional.generate(provider)
  //               // DefaultTabController(
  //               //     length: provider.optional.options!.keys.length,
  //               //     child: Column(
  //               //       children: [
  //               //         TabBar(
  //               //             tabs: provider.optional.options!.keys
  //               //                 .map((e) => Tab(
  //               //               text: e,
  //               //             ))
  //               //                 .toList()),
  //               //         TabBarView(
  //               //             children: provider.optional.options!.values
  //               //                 .map((e) => e.content(provider, e.options))
  //               //                 .toList())
  //               //       ],
  //               //     ))
  //               //     :
  //               SingleChildScrollView(
  //                   child:
  //                       // provider.styleFrom == 3 ?
  //                       provider.optional.generate(provider,0)
  //                   // : generateStyles(provider.publicStyles)
  //                   );
  //         });
  //   }
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
                    label: Text(e.name + (e.readableType ?? "")),
                    selected: provider.checkedStyles.contains(e.name),
                    onSelected: (bool selected) {
                      provider.switchChecked(selected, e.name);
                    },
                  ))
              .toList(),
        ));
      }
    }
    return Column(
      children: result,
    );
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
}
