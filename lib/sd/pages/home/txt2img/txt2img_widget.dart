import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/my_checkbox.dart';
import 'package:sd/common/third_util.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/db/History.dart';
import 'package:sd/sd/bean/enum/set_type.dart';
import 'package:sd/sd/bean4json/GenerateResultItem.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/const/sp_key.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/mocker.dart';
import 'package:sd/sd/pages/home/img2img/prompt_style_picker.dart';
import 'package:sd/sd/pages/home/img2img/prompt_widget.dart';
import 'package:sd/sd/pages/home/img2img/sampler_widget.dart';
import 'package:sd/sd/pages/home/img2img/sd_model_widget.dart';
import 'package:sd/sd/pages/home/img2img/upsacler_widget.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/pages/home/txt2img/TXT2IMGModel.dart';
import 'package:sd/sd/pages/home/txt2img/plgins/plugins_widget.dart';
import 'package:sd/sd/pages/home/txt2img/tagger_widget.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/provider/AppBarProvider.dart';
import 'package:sd/sd/widget/GenerateButton.dart';
import 'package:universal_platform/universal_platform.dart';

const TAG = "TXT2IMGWidget";

class TXT2IMGWidget extends StatelessWidget {
  final PromptStylePicker promptStylePicker = PromptStylePicker();

  final Map<IconData, Function()> actions = {};

  late AppBarProvider? appBar;

  TXT2IMGWidget({super.key});

  @override
  Widget build(BuildContext context) {
    logt(TAG, "build");
    TXT2IMGModel model = Provider.of<TXT2IMGModel>(context, listen: false);
    AIPainterModel provider =
        Provider.of<AIPainterModel>(context, listen: false);
    appBar = Provider.of<AppBarProvider?>(context, listen: false);
    String? title = provider.selectWorkspace?.getName().toUpperCase();

    if (UniversalPlatform.isAndroid) {
      actions.putIfAbsent(
          Icons.image,
          () => () {
                logt(TAG, "added action taped");
                Navigator.pushNamed(context, ROUTE_FILE_MANAGER);
              });
    }
    actions.putIfAbsent(
        Icons.image_search,
        () => () async {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context).tagger),
                      content: ChangeNotifierProvider(
                        create: (_) => TaggerModel(),
                        child: TaggerWidget(),
                      ),
                    );
                  });
            });

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
            centerTitle: true,
            leading: Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/default_portrait.png'),
                    radius: 16,
                    // CachedNetworkImage(imageUrl: provider.userInfo.protrait,
                    // placeholder: (context,url){
                    //   return const Image(image: AssetImage('placeholder/portrait.png'),);
                    // },
                    // ),
                  ),
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 8,
                        height: 8,
                        child: Selector<AIPainterModel, int>(
                            selector: (_, model) => model.netWorkState,
                            builder: (_, value, child) {
                              return CircleAvatar(
                                radius: 4,
                                backgroundColor: getStateColor(value),
                              );
                            }),
                      )),
                ],
              ),
            ),
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
      BuildContext context, TXT2IMGModel model, AIPainterModel provider) async {
    if (provider.netWorkState == ONLINE) {
      if (await checkStoragePermission()) {
        //todo autosave 在要求权限
        var from = {
          "steps":
          // provider.promptType == 3
          //     ? provider.txt2img.steps * 2
          //     :
          provider.txt2img.steps,
          "denoising_strength": 0.3,
          "firstphase_width": provider.txt2img.width,
          "firstphase_height": provider.txt2img.height,
          "enable_hr": provider.hiresFix,
          "hr_scale": provider.upscale,
          "hr_upscaler": provider.selectedUpScale,
          "hr_resize_x": provider.scalerWidth,
          "hr_resize_y": provider.scalerHeight,
          "batch_count": provider.batchCount,
          "batch_size": provider.batchSize,
          // "hr_second_pass_steps": 10,
          // "width": 1024,
          // "height": 1440,
          "restore_faces": provider.faceFix,
          "tiling": provider.tiling,
          "sampler_name": provider.txt2img.sampler,
          // "sampler_index": provider.selectedSampler,
          // "script_name": sdModelManager.getModel(provider.selectedSDModel),
          "save_images": kDebugMode,
          "seed": -1, //provider.config.seed,
        };
        // if (true) {

        String prompt = appendCommaIfNotExist(provider.txt2img.prompt) +
            promptStylePicker.getStylePrompt(provider.promptType);
        logt(TAG, prompt);
        String negativePrompt =
            appendCommaIfNotExist(provider.txt2img.negativePrompt) +
                promptStylePicker.getStyleNegPrompt();
        from['prompt'] = prompt + provider.getCheckedPluginsString();
        from['negative_prompt'] = negativePrompt;
        if (provider.generateType == 0) {
          post("$sdHttpService$TXT_2_IMG", formData: from,
                  exceptionCallback: (e) {
            Fluttertoast.showToast(
                msg: e.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER);
          }, provider: provider)
              .then((value) async {
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
                        width: provider.txt2img.width,
                        height: provider.txt2img.height,
                        imgPath: result,
                        date: now.substring(0, 10),
                        time: now.substring(10),
                        workspace: provider.selectWorkspace?.name),
                  );
                }
                //todo 自动保存之后 是不是不该显示下载按钮 或者 下载到Download
                Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
                  "datas": datas,
                  "savePath": provider.autoSave
                      ? null
                      : provider.selectWorkspace!.dirPath,
                  "scanAvailable": provider.netWorkState >= ONLINE
                });
              }
              provider.save();
            }
          });
        } else {
          // from['styles'] = provider.checkedStyles;

          post("$sdHttpService$RUN_PREDICT",
                  formData: multiGenerateBody(
                      cmd.generate,
                      from,
                      provider.batchCount,
                      provider.batchSize), exceptionCallback: (e) {
            logt(TAG, e.toString());
            Fluttertoast.showToast(
                msg: e.toString(),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER);
          }, provider: provider)
              .then((value) async {
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
              }
                Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
                  "urls": fileProt
                      .map((e) => GenerateResultItem.fromJson(e))
                      .toList(),
                  "savePath": provider.selectWorkspace!.dirPath,
                  "scanAvailable": provider.netWorkState >= ONLINE
                });

            } else {
              Fluttertoast.showToast(msg: '接口错误');
            }
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context).storagePromissionMsg,
            gravity: ToastGravity.CENTER);
      }
    } else if (provider.netWorkState == REQUESTING) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).wattingMsg,
          gravity: ToastGravity.CENTER);
    } else {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).wattingMsg,
          gravity: ToastGravity.CENTER);
    }
  }

  Widget _segments(TXT2IMGModel model) {
    return Selector<TXT2IMGModel, SetType>(
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
    return Selector<TXT2IMGModel, SetType>(
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
            selector: (_, model) => model.txt2img.width,
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
            selector: (_, model) => model.txt2img.height,
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
