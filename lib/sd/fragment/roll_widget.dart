import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/GenerateResultItem.dart';
import 'package:sd/sd/file_util.dart';
import 'package:sd/sd/model/AIPainterModel.dart';
import 'package:sd/sd/model/RollModel.dart';
import 'package:sd/sd/widget/sampler_widget.dart';

import '../../common/my_checkbox.dart';
import '../../common/third_util.dart';
import '../bean/db/History.dart';
import '../config.dart';
import '../db_controler.dart';
import '../http_service.dart';
import '../mocker.dart';
import '../pages/home_page.dart';
import '../widget/prompt_style_picker.dart';
import '../widget/prompt_widget.dart';
import '../widget/sd_model_widget.dart';
import '../widget/upsacler_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RollWidget extends StatelessWidget {
  final String TAG = "RollWidget";
  late PromptStylePicker promptStylePicker;

  RollWidget() {
    this.promptStylePicker = PromptStylePicker();
  }

  late RollModel model;
  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    final samplerManager = SamplerWidget();
    final upScalerManger = UpScalerWidget();
    model = Provider.of<RollModel>(context, listen: false);
    provider = Provider.of<AIPainterModel>(context, listen: false);
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("  ${AppLocalizations.of(context).sdModel} ："),
                Text("${AppLocalizations.of(context).workspace}：${provider.selectWorkspace?.getName()}   ")
              ],
            ),
            SDModelWidget(),
          ],
        ),
        Expanded(
          child: Stack(children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  PromptWidget(),
                  promptStylePicker,
                  // TextButton(onPressed: getSamplers, child: Text("生成")),
                  Selector<RollModel, SetType>(
                      selector: (_, model) => model.setIndex,
                      shouldRebuild: (pre, next) => pre != next,
                      builder: (context, newValue, child) =>
                          CupertinoSlidingSegmentedControl<SetType>(
                            backgroundColor: CupertinoColors.systemGrey2,
                            thumbColor: skyColors[newValue]!,
                            // This represents the currently selected segmented control.
                            groupValue: newValue,
                            // Callback that sets the selected segmented control.
                            onValueChanged: (SetType? value) {
                              if (value == SetType.lora) {
                                Navigator.pushNamed(context, ROUTE_PLUGINS);
                                // showBottomSheet(
                                //     context: context,
                                //     builder: (context) {
                                //       return PluginsWidget();
                                //     });
                              } else if (value != null) {
                                model.updateSetIndex(value);
                              }
                            },
                            children: <SetType, Widget>{
                              SetType.basic: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  AppLocalizations.of(context).basic,
                                  style: TextStyle(color: CupertinoColors.white),
                                ),
                              ),
                              SetType.advanced: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  AppLocalizations.of(context).advance,
                                  style: TextStyle(color: CupertinoColors.white),
                                ),
                              ),
                              SetType.lora: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  AppLocalizations.of(context).plugin,
                                  style: TextStyle(color: CupertinoColors.white),
                                ),
                              ),
                              // SetType.hyp: Padding(
                              //   padding: EdgeInsets.symmetric(horizontal: 20),
                              //   child: Text(
                              //     'hyp',
                              //     style: TextStyle(color: CupertinoColors.white),
                              //   ),
                              // ),
                            },
                          )),
                  Selector<RollModel, SetType>(
                    selector: (_, model) => model.setIndex,
                    shouldRebuild: (pre, next) => pre != next,
                    builder: (context, newValue, child) => IndexedStack(
                      index: newValue.index,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Selector<AIPainterModel, bool>(
                                    selector: (_, model) => model.faceFix,
                                    shouldRebuild: (pre, next) => pre != next,
                                    builder: (context, newValue, child) {
                                      return MyCheckBox(newValue, (newValue) {
                                        provider.setFaceFix(newValue!);
                                      }, AppLocalizations.of(context).faceFix);
                                    }),
                                Selector<AIPainterModel, bool>(
                                    selector: (_, model) => model.tiling,
                                    shouldRebuild: (pre, next) => pre != next,
                                    builder: (context, newValue, child) {
                                      return MyCheckBox(newValue, (newValue) {
                                        Provider.of<AIPainterModel>(context,
                                                listen: false)
                                            .setTiling(newValue!);
                                      }, AppLocalizations.of(context).tiling);
                                    }),
                              ],
                            ),
                            samplerManager,
                            Selector<AIPainterModel, int>(
                                selector: (_, model) => model.width,
                                shouldRebuild: (pre, next) => pre != next,
                                builder: (context, newValue, child) {
                                  AIPainterModel provider =
                                      Provider.of<AIPainterModel>(context);

                                  TextEditingController widthController =
                                      TextEditingController(
                                          text: provider.width.toString());
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("width"),
                                      SizedBox(
                                          width: 40,
                                          child: TextField(
                                              // initialValue: provider.samplerSteps.toString(),
                                              controller: widthController)),
                                      Slider(
                                        value: provider.width.toDouble(),
                                        min: 512,
                                        max: 2560,
                                        divisions: 16,
                                        onChanged: (double value) {
                                          print("steps seek$value");
                                          provider.updateWidth(value);
                                          // samplerStepsController.text = samplerSteps.toString();
                                        },
                                      )
                                    ],
                                  );
                                }),
                            Selector<AIPainterModel, int>(
                                selector: (_, model) => model.height,
                                shouldRebuild: (pre, next) => pre != next,
                                builder: (context, newValue, child) {
                                  AIPainterModel provider =
                                      Provider.of<AIPainterModel>(context);
                                  TextEditingController heightController =
                                      TextEditingController(
                                          text: newValue.toString());
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("height"),
                                      SizedBox(
                                          width: 40,
                                          child: TextField(
                                              // initialValue: provider.samplerSteps.toString(),
                                              controller: heightController)),
                                      Slider(
                                        value: newValue.toDouble(),
                                        min: 512,
                                        max: 2560,
                                        divisions: 16,
                                        onChanged: (double value) {
                                          print("steps seek$value");
                                          provider.updateHeight(value);
                                          // samplerStepsController.text = samplerSteps.toString();
                                        },
                                      )
                                    ],
                                  );
                                }),
                            Selector<AIPainterModel, bool>(
                              selector: (_, model) => model.hiresFix,
                              builder: (context, newValue, child) => Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Checkbox(
                                          value: newValue,
                                          onChanged: (newValue) {
                                            // setState(() {
                                            Provider.of<AIPainterModel>(context,
                                                    listen: false)
                                                .setHiresFix(newValue!);
                                            // });
                                          }),
                                      Text(AppLocalizations.of(context).hires),
                                      Text(newValue ? "resize:from to " : ""),
                                    ],
                                  ),
                                  Visibility(
                                    visible: newValue,
                                    child: child!,
                                  )
                                ],
                              ),
                              child: upScalerManger,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Selector<AIPainterModel, int>(
                                selector: (_, model) => model.batchCount,
                                shouldRebuild: (pre, next) => pre != next,
                                builder: (context, newValue, child) {
                                  TextEditingController widthController =
                                      TextEditingController(
                                          text: newValue.toString());
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(AppLocalizations.of(context).batchCount),
                                      SizedBox(
                                          width: 40,
                                          child: TextField(
                                              // initialValue: provider.samplerSteps.toString(),
                                              controller: widthController)),
                                      Slider(
                                        value: newValue.toDouble(),
                                        min: 1,
                                        max: 100,
                                        divisions: 99,
                                        onChanged: (double value) {
                                          provider.updateBatch(value);
                                          // samplerStepsController.text = samplerSteps.toString();
                                        },
                                      )
                                    ],
                                  );
                                }),
                            Selector<AIPainterModel, int>(
                                selector: (_, model) => model.batchSize,
                                shouldRebuild: (pre, next) => pre != next,
                                builder: (context, newValue, child) {
                                  TextEditingController heightController =
                                      TextEditingController(
                                          text: newValue.toString());
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(AppLocalizations.of(context).batchSize),
                                      SizedBox(
                                          width: 40,
                                          child: TextField(
                                              // initialValue: provider.samplerSteps.toString(),
                                              controller: heightController)),
                                      Slider(
                                        value: newValue.toDouble(),
                                        min: 1,
                                        max: 100,
                                        divisions: 99,
                                        onChanged: (double value) {
                                          provider.updateBatchSize(value);
                                          // samplerStepsController.text = samplerSteps.toString();
                                        },
                                      )
                                    ],
                                  );
                                }),
                          ],
                        ),
                        // TagWidget(TAG_MODELTYPE_LORA, TAG_PREFIX_LORA, GET_LORA_NAMES),
                        // TagWidget(TAG_MODELTYPE_HPE, TAG_PREFIX_HPE, GET_HYP_NAMES),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
                right: 16,
                bottom: 16,
                child: Selector<RollModel, int>(
                  selector: (_, model) => model.isGenerating,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, newValue, child) {
                    return Stack(children: [
                      child!,
                      Selector<RollModel, Uint8List?>(
                        builder: (_, newValue, child) => newValue == null
                            ? Container()
                            : Image.memory(newValue),
                        selector: (_, model) => model.previewData,
                        shouldRebuild: (pre, next) =>
                            !(next == null && pre == null),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Offstage(
                            offstage: newValue != 1,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ))
                    ]);
                  },
                  child: FloatingActionButton(
                    onPressed: () => txt2img(context),
                    child: Text(AppLocalizations.of(context).generate),
                  ),
                ))
          ]),
        )
      ],
    );
  }

  getPrompt(String prompt) =>
      appendCommaIfNotExist(prompt) + promptStylePicker.getStylePrompt();

  getNegtivePrompt(String negPrompt) =>
      appendCommaIfNotExist(negPrompt) + promptStylePicker.getStyleNegPrompt();

  txt2img(BuildContext context) async {
    if (model.isGenerating == REQUESTING) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context).wattingMsg);
    } else {
      if (await checkStoragePermission()) {
        //todo autosave 在要求权限
        model.isBusy(REQUESTING);
        String prompt = getPrompt(provider.prompt);
        String negativePrompt = getNegtivePrompt(provider.negPrompt);
        var from = {
          "prompt": prompt + provider.getCheckedPluginsString(),
          "negative_prompt": negativePrompt,
          "steps": provider.samplerSteps,
          "denoising_strength": 0.3,
          "firstphase_width": provider.width,
          "firstphase_height": provider.height,
          "enable_hr": provider.hiresFix,
          "hr_scale": provider.upscale,
          "hr_upscaler": provider.selectedUpScale,
          "hr_resize_x": provider.scalerWidth,
          "hr_resize_y": provider.scalerHeight,
          "batch_count": provider.batchCount,
          "batch_size": provider.batchSize,
          "hr_second_pass_steps": 10,
          // "width": 1024,
          // "height": 1440,
          "restore_faces": provider.faceFix,
          "tiling": provider.tiling,
          "sampler_name": provider.selectedSampler,
          // "sampler_index": provider.selectedSampler,
          // "script_name": sdModelManager.getModel(provider.selectedSDModel),
          // "save_images": true
          "seed": provider.seed,
        };
        // if (true) {
        if (provider.batchCount == 1) {
          post("$sdHttpService$TXT_2_IMG", formData: from,
              exceptionCallback: (e) {
            model.isBusy(ERROR);
            Fluttertoast.showToast(
                msg: e.toString(), toastLength: Toast.LENGTH_LONG);
          }).then((value) async {
            model.isBusy(INIT);
            provider.save();
            // saveBytes(context,value?.data["images"],provider.batchSize);
            List<Uint8List> datas = [];
            for (String item in value?.data["images"]) {
              Uint8List? bytes = base64Decode(item);
              datas.add(bytes);
              // prefs.then((sp) => {});
              if (provider.autoSave) {
                String now = DateTime.now().toString();
                logt(TAG, now.substring(0, 10));
                String fileName = "${dbString(now)}.png";
                // createFileIfNotExit(File(provider.selectWorkspace!.dirPath+"/"+fileName));
                String result = await saveBytesToLocal( bytes, fileName,
                    provider.selectWorkspace!.dirPath);
                int? insert = await DBController.instance.insertHistory(
                    History(
                        prompt: prompt,
                        negativePrompt: negativePrompt,
                        width: provider.width,
                        height: provider.height,
                        imgPath: result,
                        date: now.substring(0, 10),
                        time: now.substring(10),
                        workspace: provider.selectWorkspace?.name),
                    );
              }
            }
            if (!provider.autoSave) {
              Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER,
                  arguments: {"datas": datas,"savePath":provider.selectWorkspace!.dirPath});
            }
          });
        } else {
          post("$sdHttpService$RUN_PREDICT",
              formData: multiGenerateBody(
                  from, provider.batchCount, provider.batchSize),
              exceptionCallback: (e) {
            model.isBusy(ERROR);
            Fluttertoast.showToast(
                msg: e.toString(), toastLength: Toast.LENGTH_LONG);
          }).then((value) async {
            List fileProt = value?.data['data'][0];
            if (provider.autoSave) {
              for (int i = 1; i < fileProt.length; i++) {
                //tode 默认不保存grid
                dynamic item = fileProt[i];
                String fileName = dbString("${DateTime.now()}.png");
                String path = await saveUrlToLocal(
                    nameToUrl(item['name']),
                    fileName,
                    provider.selectWorkspace!.dirPath);
                int insert = await DBController.instance.insertHistory(History(
                    prompt: prompt,
                    negativePrompt: negativePrompt,
                    width: provider.width,
                    height: provider.height,
                    imgPath: path,
                    workspace: provider.selectWorkspace?.name));
                print('insert:$insert');
              }
            } else {
              Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
                "urls":
                    fileProt.map((e) => GenerateResultItem.fromJson(e)).toList(),
                "savePath":provider.selectWorkspace!.dirPath});
            }

            model.isBusy(INIT);
          });

          // prefs.then((sp) => {});
          //todo 异步progress轮训进度   可以封装成widget
          // _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          //   logd("tiktok");
          //   post("$sdHttpService$GET_PROGRESS",
          //       formData: getPreview(id_live_preview), exceptionCallback: (e) {
          //     _countdownTimer?.cancel();
          //   }).then((value) {
          //     if (null != value) {
          //       GenerateProgress progress = GenerateProgress.fromJson(value.data);
          //       id_live_preview = progress.idLivePreview!;
          //       model.updateProgress(progress.progress);
          //       if (progress.livePreview != null) {
          //         model.updatePreviewData(base64Decode(
          //             progress.livePreview!.substring(BASE64_PREFIX.length)));
          //       }
          //       if (progress.completed == true) {
          //         logd("timer cancel");
          //         _countdownTimer?.cancel();
          //       }
          //     }
          //   });
          // });
        }
      } else {
        Fluttertoast.showToast(msg: AppLocalizations.of(context).storagePromissionMsg);
      }
    }
  }

  int id_live_preview = -1;
  Timer? _countdownTimer;
}

enum SetType { basic, advanced, lora, hyp }

Map<SetType, Color> skyColors = <SetType, Color>{
  SetType.basic: const Color(0xff191970),
  SetType.advanced: const Color(0xff40826d),
  SetType.lora: const Color(0xff007ba7),
  SetType.hyp: const Color(0xff007ba7),
};
