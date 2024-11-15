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
    List<String> prompt = List.generate(20, (index) => "");

    //todo blist有点重  先用排他控制
    //循环所有已选择的style  按槽位拼接 lora排他
    for (PromptStyle style in provider.styles) {
      if (provider.checkedStyles.contains(style.name) &&
          !provider.inBList(style.group)) {
        if (null != style.prompt && style.prompt!.isNotEmpty) {
          var search = mixPrompt(style.step ?? 0, prompt[style.step ?? 0],
              appendCommaIfNotExist("{${style.prompt}}"));
          prompt[style.step ?? 0] = search['result'];
          if (search['exist'] == true) break;
        }
      }
      if (provider.checkedRadio.contains(style.name) &&
          !provider.inBList(style.group)) {
        if (null != style.prompt && style.prompt!.isNotEmpty) {
          var search = mixPrompt(style.step ?? 0, prompt[style.step ?? 0],
              appendCommaIfNotExist("{${style.prompt}}"));
          prompt[style.step ?? 0] = search['result'];
          if (search['exist'] == true) break;
        }
      }
    }
    // if(provider.styleFrom != 3){
    //  return "${prompt[0]}"//环境
    //       "${sfw ? "SFW," : ""}"
    //       "${prompt[2]}${prompt[9]}${prompt[1]}"//主角 主特征 关联动作  场景1
    //       "(${prompt[3]}),(${prompt[4]})\n"//主角 pose 主角衣服
    //       "{${prompt[6]}"//辅助身材
    //       "(${prompt[7]}),(${prompt[8]})\n"//辅助特征 辅助装饰
    //       "${prompt[5]}";
    // }

    int bgStep = steps * bgWeight ~/ 10;
    int mainStep = (steps - bgStep) * weight ~/ 10;
    int poseStep = steps * weight ~/ 10;

    if (provider.styleFrom == 4) {
// <<<<<<< Updated upstream
//       if(provider.txt2img.shapSteps==provider.txt2img.detailSteps){
//         return "${prompt[0]}" //环境
//             "${sfw ? "SFW," : ""}"
//             "${prompt[10].contains("<lora:")? prompt[10]:prompt[2]},${prompt[9]}," //主角 主特征 关联动作  场景1
//             "[(${prompt[3]})|(${prompt[4]},${prompt[14]},${prompt[13]})]," //主角 pose 主角衣服
//             "[(${prompt[1]})::${provider.txt2img.steps~/3}],"//前十部画大环境
//             "[(${prompt[5]}):${provider.txt2img.steps~/3}]," //后十步 画道具 装饰
//             "[(${prompt[6]})::${provider.txt2img.shapSteps}],\n" //辅助身材 辅助特征 辅助装饰
//             "[(${prompt[7]}):${provider.txt2img.steps - provider.txt2img.detailSteps}],"
//             "${prompt[8]}"; //主角 装饰
//       }else {
//         return "${prompt[0]}" //环境
//             "${sfw ? "SFW," : ""}"
//             "${prompt[10].contains("<lora:")? prompt[10]:prompt[2]},${prompt[9]}," //主角 主特征 关联动作  场景1
//             "[(${prompt[3]})::${provider.txt2img.shapSteps}],\n"
//             "[(${prompt[4]},${prompt[14]},${prompt[13]}):${provider.txt2img.steps - provider.txt2img.detailSteps}]," //主角 pose 主角衣服
//             "[(${prompt[1]})::10],"//前十部画大环境
//             "[(${prompt[5]}):${provider.txt2img.steps -10}]," //后十步 画道具 装饰
//             "[(${prompt[6]})::${provider.txt2img.shapSteps}],\n" //辅助身材 辅助特征 辅助装饰
//             "[(${prompt[7]}):${provider.txt2img.steps - provider.txt2img.detailSteps}],"
//             "${prompt[8]}"; //主角 装饰
//       }
//
// =======

      //槽位 0环境 1场景 2脸模 3主体特征 包括动作 4衣服 5点缀 6辅助脸模 7辅助体态 8辅助装饰 9互动动作
      //10 cos 强脸  11 12 13lora 主体特征 包括动作 14部位与衣物关系 19 lora 互动特征
      //todo 1. 10->12 3->13
      var result = //环境
          "${sfw ? "SFW," : ""}";
      result += prompt[0]; //todo 画质是否权重靠后

      if (prompt[1].isNotEmpty) {
        result += "[(${prompt[1]})::0.3],"; //前30%部画 大环境
      }

      result +=
          "${prompt[10].contains("<lora:") ? prompt[10] : prompt[2]},"; // todo 是否挤掉脸模
      if (provider.txt2img.shapSteps == provider.txt2img.detailSteps) {
        result +=
            // "[(${prompt[3]})::${provider.txt2img.shapSteps}],\n"
            "[(${prompt[3]},${prompt[9]})|";
        result +="(${prompt[4]},${prompt[14]})]";
      } else {
        result +=
            // "[(${prompt[3]})::${provider.txt2img.shapSteps}],\n"
            "[(${prompt[3]},${prompt[14]})::${provider.txt2img.shapSteps}],\n" //todo 2. 验证[] 里面是否可以再[]
            "[(${prompt[4]}):${provider.txt2img.steps - provider.txt2img.detailSteps}],";
      }

      //主角 pose 主角衣服
      if (prompt[1].isNotEmpty || prompt[5].isNotEmpty) {
        result += "[(${prompt[5]},${prompt[1]}):0.7],"; //后30% 画道具 装饰 +环境
      }

      if(prompt[19].isNotEmpty)result += prompt[19];
      if(prompt[13].isNotEmpty)result += prompt[13];
      result += "BREAK,"
          "[(${prompt[6]})::${provider.txt2img.shapSteps}],\n" //辅助身材 辅助特征 辅助装饰
          "[(${prompt[7]}):${provider.txt2img.steps - provider.txt2img.detailSteps}],"
          "${prompt[8]}"; //配角 装饰

      return result;
// >>>>>>> Stashed changes
    }

    //todo 过长的图用天空填充背景
    if (provider.txt2img.height > provider.txt2img.width * 1.7 ||
        provider.txt2img.width > provider.txt2img.height * 1.7) {
      return "${prompt[0]}"
          "[{beautiful detailed sky,${prompt[1]}}:{"
          "${prompt[9]}${prompt[2]}"
          "[(${prompt[3]}):(${prompt[4]}):$mainStep] "
          "{${prompt[6]}"
          "[(${prompt[7]}):(${prompt[8]}):$mainStep]}${prompt[5]}"
          "}:$bgStep]";
    } else {
      return "${prompt[0]}" //环境
          "${sfw ? "SFW," : ""}"
          "${prompt[2]}${prompt[9]}${prompt[1]}" //主角 主特征 关联动作  场景1
          "[(${prompt[3]}):(${prompt[4]}):$poseStep]\n" //主角 pose 主角衣服
          "{${prompt[6]}" //辅助身材
          "[(${prompt[7]}):(${prompt[8]}):$poseStep]\n" //辅助特征 辅助装饰
          "${prompt[5]}"; //主角 装饰
    }

    // defaultSelect bool  defaultCount 2
    //环境，细节，道具，立足点$foothold 手部道具$handProps
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
                    return Selector<AIPainterModel, bool>(
                      selector: (_, model) =>
                          model.blistCount[e] != null &&
                          model.blistCount[e]! > 0,
                      builder: (_, inBList, child) {
                        Function()? delete;
                        Color? bListColor;
                        if (!inBList) {
                          delete = () {
                            provider.unCheckStyles(e, PromptStyle.bListMap[e]);
                            provider.unCheckRadio(e, PromptStyle.bListMap[e]);
                          };
                        } else {
                          bListColor = Colors.grey;
                        }
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
                              label: Text(
                                e,
                                style: TextStyle(color: bListColor),
                              ),
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              onDeleted: delete,
                            ));
                      },
                    );
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
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(content: SDPromptWidget());
                        });
                  },
                  child: Text("prompt"),
                ),
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
                      provider.switchChecked(selected, e.name, e.bList);
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

  //严格排他lora(存在lora则丢弃其他描述)的槽位 1 2 9 4 6 8
  dynamic mixPrompt(int step, String prompt, String newPrompt) {
    // if(step==2){
    //   return {"exist":false,"result":"($prompt),($newPrompt)"};
    // }
    if (STATIC_PART.contains(step)) {
      if (prompt.contains("<lora:")) {
        return {"exist": true, "result": prompt};
      } else if (newPrompt.contains("<lora:")) {
        return {"exist": true, "result": newPrompt};
      }
    }
    return {"exist": false, "result": prompt + newPrompt};
  }

  getMainShape(List<String> prompt) {
    if (prompt[9].isNotEmpty) {
      return "[${prompt[3]}|${prompt[9]}]";
    } else {
      return prompt[3];
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
}

const STATIC_PART = [
  1,
  // 2,
  9,
  4,
  6,
  8,
];
