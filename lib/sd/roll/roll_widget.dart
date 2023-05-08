import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/provider/AppBarProvider.dart';
import 'package:sd/sd/roll/RollModel.dart';
import 'package:sd/sd/roll/plgins/plugins_widget.dart';
import 'package:sd/sd/widget/sampler_widget.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/my_checkbox.dart';
import '../../common/third_util.dart';
import '../../common/util/string_util.dart';
import '../bean/db/History.dart';
import '../bean4json/GenerateResultItem.dart';
import '../const/config.dart';
import '../db_controler.dart';
import '../http_service.dart';
import '../mocker.dart';
import '../widget/GenerateButton.dart';
import '../widget/prompt_style_picker.dart';
import '../widget/prompt_widget.dart';
import '../widget/sd_model_widget.dart';
import '../widget/upsacler_widget.dart';

class RollWidget extends StatefulWidget {
  RollWidget();

  @override
  State<RollWidget> createState() => _RollWidgetState();
}

class _RollWidgetState extends State<RollWidget> {
  final String TAG = "RollWidget";

  final PromptStylePicker promptStylePicker = PromptStylePicker();

  @override
  void initState() {
    super.initState();
  }

  Map<IconData, Function()> actions = {};

  AppBarProvider? appBar;

  // const RollWidget();
  @override
  Widget build(BuildContext context) {
    RollModel model = Provider.of<RollModel>(context, listen: false);
    AIPainterModel provider =
        Provider.of<AIPainterModel>(context, listen: false);
    appBar = Provider.of<AppBarProvider?>(context, listen: false);
    String? title = provider.selectWorkspace?.getName().toUpperCase();

    if (UniversalPlatform.isAndroid) {
      actions.putIfAbsent(
          Icons.image,
          () => () {
                logt(TAG, "added action taped");
                Navigator.pushNamed(context, ROUTE_TAVERN);
              });
    }
    actions.putIfAbsent(
        Icons.settings,
        () => () async {
              if (await checkStoragePermission()) {
                Navigator.pushNamed(context, ROUTE_SETTING);
              }
              // HistoryWidget(dbController),
            });
    if (null != appBar) {
      appBar?.updateTitle(title);
      appBar?.addActions(actions);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (null == appBar)
          AppBar(
            title: Text(title ?? ""),
            actions: actions.keys
                .map((e) => IconButton(onPressed: actions[e], icon: Icon(e)))
                .toList(),
          ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text("  ${AppLocalizations.of(context).sdModel} ："),
        //     SDModelWidget(),
        //   ],
        // ),
        Expanded(
          child: Stack(children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SDModelWidget(),
                  PromptWidget(),
                  promptStylePicker,
                  // TextButton(onPressed: getSamplers, child: Text("生成")),
                  _segments(model),
                  _stack(provider, SamplerWidget(), UpScalerWidget()),
                ],
              ),
            ),
            Positioned(
                right: 16,
                bottom: 16,
                child: GenerateButton(() => txt2img(context, model, provider)))
          ]),
        )
      ],
    );
  }

  @override
  void dispose() {}

  txt2img(
      BuildContext context, RollModel model, AIPainterModel provider) async {
    if (model.isGenerating == REQUESTING) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).wattingMsg,
          gravity: ToastGravity.CENTER);
    } else {
      if (await checkStoragePermission()) {
        //todo autosave 在要求权限
        model.isBusy(REQUESTING);
        var from = {
          "steps": provider.promptType==3?provider.config.steps*2:provider.config.steps,
          "denoising_strength": 0.3,
          "firstphase_width": provider.config.width,
          "firstphase_height": provider.config.height,
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
          "sampler_name": provider.config.sampler,
          // "sampler_index": provider.selectedSampler,
          // "script_name": sdModelManager.getModel(provider.selectedSDModel),
          "save_images": kDebugMode,
          "seed": -1,//provider.config.seed,
        };
        // if (true) {

        String prompt = appendCommaIfNotExist(provider.config.prompt) +
            promptStylePicker.getStylePrompt();
        logt(TAG, prompt);
        String negativePrompt =
            appendCommaIfNotExist(provider.config.negativePrompt) +
                promptStylePicker.getStyleNegPrompt();
        from['prompt'] = prompt + provider.getCheckedPluginsString();
        from['negative_prompt'] = negativePrompt;
        if (
            // provider.generateType == 0 &&
            provider.batchCount == 1) {
          post("$sdHttpService$TXT_2_IMG", formData: from,
              exceptionCallback: (e) {
            model.isBusy(ERROR);
            Fluttertoast.showToast(
                msg: e.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER);
          }).then((value) async {
            if (value != null) {
              logt(TAG, value.data.toString());
              // saveBytes(context,value?.data["images"],provider.batchSize);
              List<Uint8List> datas = [];
              for (String item in value.data["images"]) {
                Uint8List? bytes = base64Decode(item);
                datas.add(bytes);
                // prefs.then((sp) => {});
                if (provider.autoSave) {
                  String now = DateTime.now().toString();
                  logt(TAG, now.substring(0, 10));
                  String fileName = "${dbString(now)}.png";
                  // createFileIfNotExit(File(provider.selectWorkspace!.dirPath+"/"+fileName));
                  String result = await saveBytesToLocal(
                      bytes, fileName, provider.selectWorkspace!.absPath);
                  int? insert = await DBController.instance.insertHistory(
                    History(
                        prompt: prompt,
                        negativePrompt: negativePrompt,
                        width: provider.config.width,
                        height: provider.config.height,
                        imgPath: result,
                        date: now.substring(0, 10),
                        time: now.substring(10),
                        workspace: provider.selectWorkspace?.name),
                  );
                } else {
                  Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
                    "datas": datas,
                    "savePath": provider.selectWorkspace!.dirPath,
                    "scanAvailable": provider.sdServiceAvailable
                  });
                }
              }
              model.isBusy(INIT);
              provider.save();
            }
          });
        } else {
          // from['styles'] = provider.checkedStyles;

          post("$sdHttpService$RUN_PREDICT",
              formData: multiGenerateBody(
                  from, provider.batchCount, provider.batchSize),
              exceptionCallback: (e) {
            logt(TAG, e.toString());
            model.isBusy(ERROR);
            Fluttertoast.showToast(
                msg: e.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER);
          }).then((value) async {
            logt(TAG, value?.data?.toString() ?? "null");
            List? fileProt = value?.data['data'][0];
            if (null != fileProt) {
              if (provider.autoSave) {
                for (int i = 1; i < fileProt.length; i++) {
                  //tode 默认不保存grid
                  dynamic item = fileProt[i];
                  String fileName = dbString("${DateTime.now()}.png");
                  String path = await saveUrlToLocal(nameToUrl(item['name']),
                      fileName, provider.selectWorkspace!.dirPath);

                  // provider.lastGenerate = value.data['data'][0][0]['name'];
                  // Fluttertoast.showToast(
                  //     msg: '生成成功:远端地址 ${provider.lastGenerate}');

                  // int insert = await DBController.instance.insertHistory(History(
                  //     prompt: provider.config.prompt,
                  //     negativePrompt: negativePrompt,
                  //     width: provider.config.width,
                  //     height: provider.config.height,
                  //     imgPath: path,
                  //     workspace: provider.selectWorkspace?.name));
                  // print('insert:$insert');
                }
              } else {
                Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
                  "urls": fileProt!
                      .map((e) => GenerateResultItem.fromJson(e))
                      .toList(),
                  "savePath": provider.selectWorkspace!.dirPath,
                  "scanAvailable": provider.sdServiceAvailable
                });
              }
            } else {
              Fluttertoast.showToast(msg: '接口错误');
            }

            model.isBusy(INIT);
          });

          // prefs.then((sp) => {});
          //todo 异步progress轮训进度   可以封装成widget
          model.backgroundProgress = false;
        }
      } else {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).storagePromissionMsg,
            gravity: ToastGravity.CENTER);
      }
    }
  }

  Widget _segments(RollModel model) {
    return Selector<RollModel, SetType>(
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
                  if (isMobile()) {
                    Navigator.pushNamed(context, ROUTE_PLUGINS);
                  } else {
                    showBottomSheet(
                        context: context,
                        builder: (context) {
                          return const PluginsWidget();
                        });
                  }
                } else if (value != null) {
                  model.updateSetIndex(value);
                }
              },
              children: <SetType, Widget>{
                SetType.basic: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context).basic,
                    style: const TextStyle(color: CupertinoColors.white),
                  ),
                ),
                SetType.advanced: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context).advance,
                    style: const TextStyle(color: CupertinoColors.white),
                  ),
                ),
                SetType.lora: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Selector<AIPainterModel, int?>(
                        selector: (_, model) =>
                            model.checkedPlugins.values.length,
                        builder: (context, value, child) {
                          return value == null || value == 0
                              ? child!
                              : Badge(
                                  child: child,
                                  label: Text(value.toString()),
                                );
                        },
                        child: Text(
                          AppLocalizations.of(context).plugin,
                          style: const TextStyle(color: CupertinoColors.white),
                        ))),
                // SetType.hyp: Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: Text(
                //     'hyp',
                //     style: TextStyle(color: CupertinoColors.white),
                //   ),
                // ),
              },
            ));
  }

  Widget _stack(AIPainterModel provider, Widget sampler, Widget upScaler) {
    return Selector<RollModel, SetType>(
        selector: (_, model) => model.setIndex,
        shouldRebuild: (pre, next) => pre != next,
        builder: (context, newValue, child) => IndexedStack(
              index: newValue.index,
              children: [
                _basic(provider, sampler, upScaler),
                Column(
                  children: [
                    Selector<AIPainterModel, int>(
                        selector: (_, model) => model.batchCount,
                        shouldRebuild: (pre, next) => pre != next,
                        builder: (context, newValue, child) {
                          TextEditingController widthController =
                              TextEditingController(text: newValue.toString());
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              TextEditingController(text: newValue.toString());
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ));
  }

  Widget _basic(AIPainterModel provider, Widget sampler, Widget upScaler) {
    return Column(
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
                    Provider.of<AIPainterModel>(context, listen: false)
                        .setTiling(newValue!);
                  }, AppLocalizations.of(context).tiling);
                }),
            // Selector<AIPainterModel, int>(
            //     selector: (_, model) => model.config.seed,
            //     shouldRebuild: (pre, next) => pre != next,
            //     builder: (context, newValue, child) {
            //       TextEditingController control =
            //           TextEditingController(text: newValue.toString());
            //       return Row(
            //         children: [
            //           TextFormField(controller: control),
            //           IconButton(
            //               onPressed: () {
            //                 post("$sdHttpService$RUN_PREDICT",
            //                         formData: refreshModel())
            //                     .then((value) {
            //                   // logt(TAG, value.toString());
            //                   double seed = value!.data['data'][0];
            //                   control.text = seed.toInt.toString();
            //                 });
            //               },
            //               icon: Icon(Icons.refresh))
            //         ],
            //       );
            //     }),
          ],
        ),
        sampler,
        Selector<AIPainterModel, int>(
            selector: (_, model) => model.config.width,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              AIPainterModel provider = Provider.of<AIPainterModel>(context);

              TextEditingController widthController =
                  TextEditingController(text: newValue.toString());
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("width"),
                  SizedBox(
                      width: 40,
                      child: TextField(
                          // initialValue: provider.samplerSteps.toString(),
                          controller: widthController)),
                  Slider(
                    value: newValue.toDouble(),
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
            selector: (_, model) => model.config.height,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              AIPainterModel provider = Provider.of<AIPainterModel>(context);
              TextEditingController heightController =
                  TextEditingController(text: newValue.toString());
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                      value: newValue,
                      onChanged: (newValue) {
                        // setState(() {
                        Provider.of<AIPainterModel>(context, listen: false)
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
          child: upScaler,
        ),
      ],
    );
  }
}

enum SetType { basic, advanced, lora, hyp }

Map<SetType, Color> skyColors = <SetType, Color>{
  SetType.basic: const Color(0xff191970),
  SetType.advanced: const Color(0xff40826d),
  SetType.lora: const Color(0xff007ba7),
  SetType.hyp: const Color(0xff007ba7),
};
