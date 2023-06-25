import 'dart:async';
import 'dart:convert';

import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/provider/network_model.dart';

import '../../../../common/third_util.dart';
import '../../../../common/ui_util.dart';
import '../../../../common/util/file_util.dart';
import '../../../../common/util/ui_util.dart';
import '../../../bean4json/PostPredictResult.dart';
import '../../../const/config.dart';
import '../../../http_service.dart';
import '../../../mocker.dart';
import '../../../provider/AIPainterModel.dart';
import '../../../widget/file_prompt_reader.dart';

//todo 图片识别默认模型 从配置读取
String DEFAULT_INTERROGATOR = 'wd14-vit';

class TaggerModel with ChangeNotifier, DiagnosticableTreeMixin {
  String? generate_prompt = "";

  int threshold = 30;

  Uint8List? selectedBytes;

  String taggerText = "";

  void updateTaggerText(String value) {
    taggerText = value;
    logt(TAG, "tagger updated");

    notifyListeners();
  }

  void updateBytes(Uint8List uint8list) {
    selectedBytes = uint8list;
    notifyListeners();
  }

  void updateThreshold(int value) {
    threshold = value;
    notifyListeners();
  }

  void updatePrompt(String? prompt) {
    this.generate_prompt = prompt;
    notifyListeners();
  }
}

final String TAG = "TaggerWidget";

class TaggerWidget extends StatelessWidget {
  TaggerWidget();

  List<String>? interrogators;

  late AIPainterModel provider;
  late TaggerModel model;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    model = Provider.of<TaggerModel>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              XFile? target = await showModalBottomSheet(
                  useRootNavigator: true,
                  // useSafeArea: true,
                  constraints: const BoxConstraints.expand(height: 98),
                  context: context,
                  builder: (context) {
                    return Column(
                      children: [
                        bottomSheetItem("从相册选择", () async {
                          if (await checkStoragePermission()) {
                            Navigator.pop(
                                context,
                                await loadFileToImageAndReturnPromptIfPosoable(
                                    ImageSource.gallery));
                          }
                        }),
                        const Divider(
                          height: 2,
                        ),
                        bottomSheetItem("拍摄", () async {
                          if (await checkStoragePermission()) {
                            Navigator.pop(
                                context,
                                await loadFileToImageAndReturnPromptIfPosoable(
                                    ImageSource.camera));
                          }
                        })
                      ],
                    );
                  });

              String? prompt;
              if (null != target) {
                Uint8List bytes = await target.readAsBytes();
                model.updateBytes(bytes);
                if (target.name.endsWith(".png") ||
                    target.name.endsWith(".PNG")) {
                  prompt = getPNGExtData(bytes);
                } else {
                  var exif = await readExifFromBytes(bytes);
                  logt(TAG, "jpeg exif:" + exif.toString());
                  prompt = exif.toString();
                }
                model.updatePrompt(prompt);

                await syncTagger(cmd.getImageTaggers,bytes,provider.selectedInterrogator,model.threshold,model.updateTaggerText);
              }
            },
            child: Selector<TaggerModel, Uint8List?>(
                selector: (_, model) => model.selectedBytes,
                shouldRebuild: (pre, next) => next != pre,
                builder: (context, newValue, child) {
                  if (null != newValue) {
                    Image image = Image.memory(newValue!);
                    return AspectRatio(
                      aspectRatio: newValue == null ||
                              image.width == null ||
                              image.height == null
                          ? 786 / 512
                          : (image.width! / image.height!).toDouble(),
                      child: newValue == null
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3.0)),
                              ),
                            )
                          : image,
                    );
                  } else {
                    return AspectRatio(aspectRatio: 786 / 512);
                  }
                }),
          ),
          FutureBuilder(
            future: post("$sdHttpService$RUN_PREDICT",
                formData: {
                  "fn_index": cmd.refreshInterrogators,
                  "data": [],
                  // "session_hash": "lcm8sq8kso"
                }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                RunPredictResult result =
                    RunPredictResult.fromJson(snapshot.data?.data);
                // logt(TAG,result.data[0].choices.toString());
                interrogators = result.data[0].choices;
                return Selector<AIPainterModel, String>(
                  selector: (_, model) => model.selectedInterrogator,
                  shouldRebuild: (pre, next) => pre != next,
                  builder: (context, newValue, child) {
                    return DropdownButton(
                        value: newValue,
                        // hint: Text(selectedUpScale != null
                        //     ? "${selectedUpScale!.name}"
                        //     : "请选择模型"),
                        items: getStringItems(interrogators!),
                        onChanged: (newValue) {
                          provider.selectInterrogator(newValue);
                        });
                  },
                );
              } else {
                return myPlaceholder(100, 18);
              }
            },
          ),
          Text(AppLocalizations.of(context).threshold + ":"),
          Selector<TaggerModel, int>(
            selector: (_, model) => model.threshold,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              TextEditingController thresholdController =
                  TextEditingController(text: newValue.toString());

              TaggerModel tagger = Provider.of(context, listen: false);
              return Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: thresholdController,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: newValue.toDouble(),
                      min: 30,
                      max: 90,
                      divisions: 12,
                      onChanged: (double value) {
                        tagger.updateThreshold(value.toInt());
                        thresholdController.text = value.toInt().toString();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          Selector<TaggerModel, String?>(
            selector: (_, model) => model.generate_prompt,
            shouldRebuild: (pre, next) => pre != next,
            builder: (_, newValue, child) {
              return Offstage(
                offstage: null == newValue || newValue.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("文件头"),
                        Spacer(),
                        IconButton(
                            onPressed: () {
                              provider.updatePrompt(newValue);
                            },
                            icon: const RotatedBox(
                                quarterTurns: -1,
                                child: Icon(Icons.merge_type))),
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: newValue!));
                              Fluttertoast.showToast(
                                  msg: "关键词已复制到剪切板",
                                  gravity: ToastGravity.CENTER);
                            },
                            icon: const Icon(Icons.copy_all)),
                      ],
                    ),
                    SelectableText(maxLines: 5, newValue!),
                  ],
                ),
              );
            },
          ),
          Selector<TaggerModel, String>(
            selector: (_, model) => model.taggerText,
            builder: (_, newValue, child) {
              logt(TAG, "resolve newValue $newValue");
              return Offstage(
                offstage: newValue.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text("AI识别关键词"),
                      Spacer(),
                      IconButton(
                          onPressed: () {
                            provider.updatePrompt(newValue);
                          },
                          icon: const RotatedBox(
                              quarterTurns: -1, child: Icon(Icons.merge_type))),
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: newValue));
                            Fluttertoast.showToast(
                                msg: "关键词已复制到剪切板",
                                gravity: ToastGravity.CENTER);
                          },
                          icon: const Icon(Icons.copy_all)),
                    ]),
                    SelectableText(maxLines: 5, newValue),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<XFile?> loadFileToImageAndReturnPromptIfPosoable(
      ImageSource source) async {
    ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: source);
  }
}

Future<void> syncTagger(int cmd,Uint8List bytes,String interrogator,int threshold,Function(String) callback) async {
  String encode = const Base64Encoder().convert(bytes);
  await post("$sdHttpService$RUN_PREDICT",
      formData: tagger(cmd,
          encode, interrogator,threshold / 100.0),
      exceptionCallback: (e) {
        logt(TAG, e.toString());
      }).then((value) {
    callback(value?.data['data'].toString() ?? "");
  });
}
