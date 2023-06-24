import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/PromptStyle.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../../common/util/string_util.dart';
import '../../../bean/Optional.dart';
import '../../../http_service.dart';

class PromptStylePicker extends StatelessWidget {
  PromptStylePicker();

  String getStylePrompt() {
    String prompt = "";
    for (PromptStyle style in provider.styles) {
      if (provider.checkedStyles.contains(style.groupName)) {
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
      if (!provider.isHidden(style.groupName)&&provider.checkedStyles.contains(style.groupName)) {
        if (null != style.prompt && style.prompt!.isNotEmpty) {
          prompt[style.step ?? 0] += appendCommaIfNotExist("{${style.prompt}}");
        }
      }
      if (!provider.isHidden(style.groupName)&&provider.checkedRadio.contains(style.name)) {
        if (null != style.prompt && style.prompt!.isNotEmpty) {
          prompt[style.step ?? 0] += appendCommaIfNotExist("{${style.prompt}}");
        }
      }
    }

    int bgStep = steps * bgWeight ~/ 10;
    int mainStep = (steps - bgStep) * weight ~/ 10;
    if (provider.txt2img.height > provider.txt2img.width * 1.7||provider.txt2img.width > provider.txt2img.height * 1.5) {
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
          "${sfw ? "((sfw))," : ""}"
          "${prompt[1]}${prompt[9]}${prompt[2]}"
          "[(${prompt[3]}):(${prompt[4]}):$poseStep] "
          "{${prompt[6]}"
          "[(${prompt[7]}):(${prompt[8]}):$poseStep]}${prompt[5]}";
    }
  }

  String getStyleNegPrompt() {
    String prompt = sfw ? "((nsfw))," : "";
    for (PromptStyle style in provider.styles) {
      if (provider.checkedStyles.contains(style.groupName)) {
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
    return Row(children: [
      Expanded(
        child: Wrap(
          spacing: 8,
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          children: ([]
                ..addAll(provider.checkedStyles)
                ..addAll(provider.checkedRadio))
              .map((e) => Selector<AIPainterModel, int>(
                    selector: (_, model) =>
                        model.lockedRadioGroup.length +
                        model.lockedStyles.length,
                    builder: (_, value, child) {
                      return GestureDetector(
                          onTap: () {
                            if(isSingle(e)){
                              provider.lockSingle(e);
                            }else{
                              provider.lockMultiple(e);
                            }
                          },
                          child: RawChip(
                            avatar: (provider.radioLocked(e) ||
                                    provider.lockedStyles.contains(e))
                                ? CircleAvatar(
                                    radius: 6,
                                    child: Container(
                                      color: Colors.red,
                                    ),
                                  )
                                : null,
                            label: provider.isHidden(provider.fillGroupIfSingle(e))
                                ? Text(
                                    groupFilter(e),
                                    style: const TextStyle(
                                        decoration: TextDecoration.lineThrough),
                                  )
                                : Text(groupFilter(e)),
                            onDeleted: () {
                              provider.unCheckStyles(e);
                              provider.unCheckRadio(e);
                            },
                          ));
                    },
                  ))
              .toList(),
        ),
      ),
      Column(
        children: [
          // IconButton(
          //     onPressed: () => showStyleDialog(context),
          //     icon: const Icon(Icons.add_box_outlined)),
          Selector<AIPainterModel, bool>(
            selector: (_, model) =>
                model.checkedStyles.isEmpty && model.checkedRadio.isEmpty,
            builder: (_, newValue, child) {
              return Offstage(
                offstage: newValue,
                child: Column(
                  children: [
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
      showBottomSheet(
          context: context,
          builder: (context) {
            AIPainterModel provider = Provider.of<AIPainterModel>(context);
            return
                // provider.promptType == 3
                //     ?
                // //provider.optional.generate(provider)
                // DefaultTabController(
                //     length: provider.optional.options!.keys.length,
                //     child: Column(
                //       children: [
                //         TabBar(
                //             tabs: provider.optional.options!.keys
                //                 .map((e) => Tab(
                //               text: e,
                //             ))
                //                 .toList()),
                //         TabBarView(
                //             children: provider.optional.options!.values
                //                 .map((e) => e.content(provider, e.options))
                //                 .toList())
                //       ],
                //     ))
                //     :
                SingleChildScrollView(
                    child:
                        // provider.styleFrom == 3 ?
                        provider.optional.generate(provider)
                    // : generateStyles(provider.publicStyles)
                    );
          });
    }
  }

  Widget generateStyles(Map<String, List<PromptStyle>?> map) {
    List<Widget> result = [];
    for (String key in map.keys) {
      List<PromptStyle>? value = map[key];
      if (value != null && value.isNotEmpty) {
        result.add(Text(key));
        result.add(Wrap(
          children: value
              .map((e){
                return RawChip(
                  label: Text(e.name + (e.readableType ?? "")),
                  selected: provider.checkedStyles.contains(e.groupName),
                  onSelected: (bool selected) {
                    provider.switchChecked(selected,e.groupName);
                  },
                );
          })
              .toList(),
        ));
      }
    }
    return Column(
      children: result,
    );
  }

  String groupFilter(String e) {
    var offset = e.lastIndexOf('|');
    if (offset < 0) {
      return e;
    }
    return e.substring(offset + 1);
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
