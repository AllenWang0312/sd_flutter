import 'dart:convert';

import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;
import 'package:provider/provider.dart';
import 'package:sd/sd/model/HomeModel.dart';
import 'package:sd/sd/model/RollModel.dart';

import '../../common/third_util.dart';
import '../../common/ui_util.dart';
import '../http_service.dart';
import '../mocker.dart';
import '../bean/PostPredictResult.dart';
import '../config.dart';
import '../model/AIPainterModel.dart';
import '../ui_util.dart';

//todo 图片识别默认模型 从配置读取
String DEFAULT_INTERROGATOR = 'wd14-vit-v2-git';

class TaggerModel with ChangeNotifier, DiagnosticableTreeMixin {
  String generate_prompt = "";

  int threshold = 30;

  Uint8List? selectedBytes;

  String taggerText = "";

  void updateTaggerText(String value) {
    taggerText = value;
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

  void updatePrompt(String prompt) {
    this.generate_prompt = prompt;
    notifyListeners();
  }
}

class TaggerWidget extends StatelessWidget {
  final String TAG = "TaggerWidget";
  TaggerWidget();

  List<String>? interrogators;

  late AIPainterModel provider;
  late TaggerModel model;

  @override
  Widget build(BuildContext context) {
    provider =
        Provider.of<AIPainterModel>(context, listen: false);
    model = Provider.of<TaggerModel>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              String prompt = await showModalBottomSheet(
                  useRootNavigator: true,
                  // useSafeArea: false,
                  constraints: const BoxConstraints.expand(height: 98),
                  context: context,
                  builder: (context) {
                    return Column(
                      children: [
                        bottomSheetItem("从相册选择", () async {
                          String prompt =
                              await loadFileToImage(ImageSource.gallery);
                          Navigator.pop(context, prompt);
                        }),
                        const Divider(
                          height: 2,
                        ),
                        bottomSheetItem("拍摄", () async {
                          String prompt =
                              await loadFileToImage(ImageSource.camera);
                          Navigator.pop(context, prompt);
                        })
                      ],
                    );
                  });
              model.updatePrompt(prompt);
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
                formData: getInterrogators()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                RunPredictResult result =
                    RunPredictResult.fromJson(snapshot.data?.data);
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
                return const Placeholder(
                  fallbackHeight: 18,
                  fallbackWidth: 100,
                );
              }
            },
          ),
          Text('   出现概率大于多少显示（%） '),
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
          Selector<TaggerModel, String>(
            selector: (_, model) => model.generate_prompt,
            shouldRebuild: (pre, next) => pre != next,
            builder: (_, newValue, child) {
              return Offstage(
                offstage: newValue.isEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("生成关键词"),
                        Spacer(),
                        IconButton(
                            onPressed: () {
                              provider.updatePrompt(model.generate_prompt);
                            },
                            icon: const RotatedBox(
                                quarterTurns: -1,
                                child: Icon(Icons.merge_type))),
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: model.generate_prompt));
                              Fluttertoast.showToast(msg: "关键词已复制到剪切板");
                            },
                            icon: const Icon(Icons.copy_all)),
                      ],
                    ),
                    SelectableText(maxLines: 5, newValue),
                  ],
                ),
              );
            },
          ),
          Selector<TaggerModel, String>(
            selector: (_, model) => model.taggerText,
            shouldRebuild: (pre, next) => pre != next,
            builder: (_, newValue, child) {
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
                            provider.updatePrompt(model.taggerText);
                          },
                          icon: const RotatedBox(
                              quarterTurns: -1, child: Icon(Icons.merge_type))),
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: model.taggerText));
                            Fluttertoast.showToast(msg: "关键词已复制到剪切板");
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

  getImageTagger(Uint8List? bytes, int threshold) {
    if (null != bytes) {
      String encode = Base64Encoder().convert(bytes);
      post("$sdHttpService$RUN_PREDICT",
              formData: tagger(encode, threshold / 100),
              exceptionCallback: (e) {})
          .then((value) {
        model.updateTaggerText(value?.data['data'][0]);
      });
    }
  }

  Future<String> loadFileToImage(ImageSource source) async {
    if (await checkStoragePermission()) {
      ImagePicker picker = ImagePicker();
      XFile? file = await picker.pickImage(source: source);
      if (null != file) {
        Uint8List bytes = await file.readAsBytes();
        model.updateBytes(bytes);
        getImageTagger(model.selectedBytes, model.threshold);

        if (file.name.endsWith(".png") || file.name.endsWith(".PNG")) {
          var chunks = pngExtract.extractChunks(bytes);
          var scanChunkName = "tEXt";

          for (Map chunk in chunks) {
            for (String key in chunk.keys) {
              if (chunk[key].toString() == scanChunkName) {
                return Future.value(String.fromCharCodes(chunk['data']));
              }
            }
          }
        } else {
          var exif = await readExifFromBytes(bytes);
          logt(TAG,"jpeg exif:" + exif.toString());
        }
        return Future.value("");
      }
    }
    return Future.error("");
  }
}
