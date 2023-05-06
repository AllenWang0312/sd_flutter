import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/tavern/bean/UniqueSign.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/roll/tagger_widget.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../common/third_util.dart';
import '../const/config.dart';
import '../mocker.dart';
import '../http_service.dart';
import '../widget/AgeLevelCover.dart';

const String TAG = "ImageViewer";

class ExtInfo {
  String? prompts;
  String? remoteFilePath;
  bool favourite = false;
}

class ImagesModel with ChangeNotifier, DiagnosticableTreeMixin {
  String? currentRemoteFilePath;

  int index = 0;

  List<ExtInfo?> exts = [];

  void pageChanged(int index) {
    this.index = index;
    notifyListeners();
  }

  void updateCurrentDes(int index, String? des) {
    this.index = index;
    exts[index]?.prompts = des;
    notifyListeners();
  }

  void updateRemoteFilePath(int page, String data) {
    exts[page]?.remoteFilePath = data;
    notifyListeners();
  }

  void updateFavourete(int page, bool bool) {
    exts[page]?.favourite = bool;
    notifyListeners();
  }

  void removeExtsAt(int index) {
    exts.removeAt(index);
    if (this.index == index) {
      this.index--;
    }

    notifyListeners();
  }

  void updateIndex(int page) {
    index = page;
    notifyListeners();
  }

  void initExts(int size) {
    exts = [];
    for (int i = 0; i < size; i++) {
      exts.add(ExtInfo());
    }
    notifyListeners();
  }
}

enum ImagesType {
  datas,
  urls,
  files,
}

class ImagesViewer<T extends UniqueSign> extends StatelessWidget {
  int? pageSize;
  int? pageNum;
  int? index;

  // late Function? loadMore;
  List<T>? urls;
  List<Uint8List?> datas = [];

  String? relativeSaveDirPath;
  bool scanServiceAvailable;

  bool? isFavourite;
  String? type;
  int fnIndex; //remote +3 fav-10 del -12

  late ImagesType dataType;

  ImagesViewer(
      {this.urls,
      this.index,
        this.fnIndex = 0,
      // this.loadMore,
      List<Uint8List>? datas,
      this.relativeSaveDirPath,
      this.scanServiceAvailable = false,
      this.isFavourite = true,
      this.type = 'txt2img'}) {
    if (datas != null) {
      dataType = ImagesType.datas;
      this.datas.addAll(datas);
    } else {
      if (urls != null) {
        this.datas = List<Uint8List?>.filled(urls!.length, null);
        if (urls![0].getFileLocation().startsWith('http')) {
          dataType = ImagesType.urls;
        } else {
          dataType = ImagesType.files;
        }
      }
    }
  }

  late AIPainterModel provider;

  late ImagesModel images;

  List<String>? removedItems;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    images = Provider.of<ImagesModel>(context, listen: false);

    if (urls != null) {
      // List<ExtInfo?>.filled(urls!.length, ExtInfo(),growable: true) //会导致所有的item指向同一个bean
      images.initExts(urls!.length);
    }

    PageController controller = PageController(initialPage: index ?? 0);
    if (null != urls) {
      onPageChange(index ?? 0);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, removedItems ?? images.index);
          },
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Selector<ImagesModel, String?>(
            selector: (_, model) => images.exts[model.index]?.prompts,
            builder: (context, value, child) {
              return Offstage(
                offstage: value == null || value.isEmpty,
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showPromptDialog(provider, context, value!),
                ),
              );
            },
          ),
          Selector<ImagesModel, bool>(
            selector: (_, model) => images.exts[model.index]!.favourite,
            builder: (context, value, child) {
              return Offstage(
                  offstage: true == isFavourite,
                  child: IconButton(
                    icon: Icon(value
                        ? Icons.favorite_outlined
                        : Icons.favorite_border),
                    onPressed: () async {
                      if (value) {
                        Fluttertoast.showToast(msg: '暂不支持取消');
                      } else {
                        int? page = controller.page?.toInt();
                        if (null != page) {
                          String? remoteFilePath =
                              images.exts[page]?.remoteFilePath;
                          if (null != remoteFilePath) {
                            await post("$sdHttpService$RUN_PREDICT",
                                    formData: addToFavourite(fnIndex-10,remoteFilePath))
                                .then((value) {
                              images.updateFavourete(page, true);
                            });
                          }
                        }
                      }
                    },
                  ));
            },
          ),
          Offstage(
            offstage: relativeSaveDirPath == null,
            child: IconButton(
              onPressed: () async {
                if (await checkStoragePermission()) {
                  if (datas != null) {
                    dynamic result = await saveBytesToLocal(
                        datas[controller.page!.toInt()],
                        "${DateTime.now()}.png",
                        asyncPath + relativeSaveDirPath!);
                    Fluttertoast.showToast(msg: result.toString());
                  } else {
                    dynamic result = await saveUrlToLocal(
                        urls![controller.page!.toInt()].getFileLocation(),
                        "${DateTime.now()}.png",
                        asyncPath + relativeSaveDirPath!);
                    Fluttertoast.showToast(msg: result.toString());
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "请允许应用使用存储权限", gravity: ToastGravity.CENTER);
                }
              },
              icon: const Icon(Icons.download),
            ),
          ),
          Offstage(
            offstage: !scanServiceAvailable,
            child: IconButton(
                onPressed: () async {
                  int? page = controller.page?.toInt();
                  if (null != page) {
                    Uint8List bytes = await getBytes(page);
                    await syncTagger(bytes, provider.selectedInterrogator, 30,
                        (tagger) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Tagger"),
                              content: SelectableText(tagger),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: tagger));
                                    },
                                    child: const Text("复制")),
                                // TextButton(
                                //     onPressed: () {
                                //       Clipboard.setData(
                                //           ClipboardData(text: tagger));
                                //     },
                                //     child: Text("复制")),
                              ],
                            );
                          });
                    });
                  }
                  // provider.
                },
                icon: const Icon(Icons.settings_overscan)),
          ),
          TextButton(onPressed: () async {
            var width = MediaQuery.of(context).size.width;
            var height = MediaQuery.of(context).size.height;
            // await Wallpaper.homeScreen(
            //     options: RequestSizeOptions.RESIZE_FIT,
            //     width: width,
            //     height: height,
            //   // location: DownloadLocation()
            //   );
            print("Task Done");

          }, child: Text('设为壁纸'))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: null == urls
                  ? PageView.builder(
                      controller: controller,
                      itemCount: datas.length,
                      itemBuilder: (context, index) {
                        return interactiveView(Image.memory(datas[index]!));
                      })
                  : Selector<ImagesModel, int>(
                      selector: (_, model) => model.exts.length,
                      builder: (context, newValue, child) {
                        logt(TAG, "rebuild pageview");
                        return PageView.builder(
                            onPageChanged: onPageChange,
                            controller: controller,
                            itemCount: newValue,
                            itemBuilder: (context, index) {
                              T? data = urls?[index];
                              // bool isRemote =
                              //     data.getFileLocation().startsWith("http");
                              if (null != data) {
                                return urlBuilder(context, index, data);
                              }
                            });
                      },
                    ),
            ),
          ),
          TextButton(
              onPressed: () async {
                var width = MediaQuery.of(context).size.width;
                var height = MediaQuery.of(context).size.height;
//             await Wallpaper.homeScreen(
//                 options: RequestSizeOptions.RESIZE_FIT,
//                 width: width,
//                 height: height);
//             print("Task Done");
              },
              child: Text('设为壁纸'))
        ],
      ),
    );
  }

  onPageChange(int page) async {
    UniqueSign item = urls![page];

    if (null!=type&&item.getFileLocation().startsWith("http")) {
      images.updateIndex(page);
      String? currentRemotePath = images.exts[page]?.remoteFilePath;
      if (null == currentRemotePath) {
        await post("$sdHttpService$RUN_PREDICT",
            formData: getRemoteHistoryInfo(
              fnIndex+3,
              page % 36,
              page ~/ 36 + 1,type!
            )).then((value) {
          String currentRemoteFilePath = value!.data?['data'][0];
          images.updateRemoteFilePath(page, currentRemoteFilePath);
          // images.currentRemoteFilePath(value!.data?['data'][0]);
          logt(TAG, "get Remote Info $currentRemoteFilePath");
        });
      }
    } else if(null!=urls){
      images.updateCurrentDes(page, urls![page].getPrompts());
    }
  }

  PopupMenuItem itemMenu(int age) {
    return PopupMenuItem(
      value: age,
      child: Text('设置年龄分级:$age+'),
    );
  }

  Future<Uint8List> getBytes(int page) async {
    if (null != datas &&
        page >= 0 &&
        page < datas.length &&
        datas[page] != null) {
      return datas[page]!;
    } else {
      T showable = urls![page];
      String url = showable.getFileLocation();
      Uint8List bytes;
      if (url.startsWith('http')) {
        bytes = await getBytesWithDio(url);
      } else {
        bytes = File(url).readAsBytesSync();
      }
      datas[page] = bytes;
      return bytes;
    }
  }

  interactiveView(Widget widget) {
    return InteractiveViewer(maxScale: 3, minScale: 0.5, child: widget);
  }

  Widget urlBuilder(BuildContext context, int index, T data) {
    File? file;
    if (dataType == ImagesType.files) {
      file = File(data.getFileLocation());
      datas[index] = file.readAsBytesSync();
    }
    // FileInfo fileInfo = data as FileInfo;

    return GestureDetector(
      onLongPressStart: (detail) async {
        // if(null!=file){
        //   FileStat stat = await file.stat();
        //   fileInfo.fileSize = stat.size;
        // }
        int currentLevel = await data.getAgeLevel(provider, datas[index]);

        RelativeRect position = RelativeRect.fromLTRB(detail.globalPosition.dx,
            detail.globalPosition.dy, double.infinity, double.infinity);
        if (context.mounted) {
          showMenu(context: context, position: position, items: [
            if (images.exts[index]?.remoteFilePath != null)
              const PopupMenuItem(value: -100, child: Text('删除文件')),
            if (currentLevel != 12) itemMenu(12),
            if (currentLevel != 16) itemMenu(16),
            if (currentLevel != 18) itemMenu(18),
            if (currentLevel > 0)
              const PopupMenuItem(
                value: -1,
                child: Text('取消年龄分级'),
              )
          ]).then((value) async {
            if (value > 0) {
              if (currentLevel > 0) {
                if (await DBController.instance
                        .updateAgeLevelRecord(data, datas[index], value) >
                    0) {
                  data.setAgeLevel(provider, value);
                }
              } else {
                if (await DBController.instance
                        .insertAgeLevelRecord(data, datas[index], value) >
                    0) {
                  data.setAgeLevel(provider, value);
                }
              }
            } else if (value == -100) {
              // if (images.remoteFilePath[index] != null) {
              post("$sdHttpService$RUN_PREDICT",
                      formData: delateFile(fnIndex-12,images.exts[index]?.remoteFilePath,
                          index ~/ 36 + 1, index % 36, 36))
                  .then((value) {
                logt(TAG, "delete file$value");

                urls?.removeAt(index);
                images.removeExtsAt(index);
                removedItems ??= [];
                removedItems?.add(data.getFileLocation());
                onPageChange(index);
              });
              // }
            } else {
              if (await DBController.instance
                      .removetAgeLevelRecord(data, datas[index]) >
                  0) {
                data.setAgeLevel(provider, 0);
              }
            }
          });
        }
      },
      child: interactiveView(dataType == ImagesType.urls
          ? CachedNetworkImage(imageUrl: (data.getFileLocation()))
          : Image.memory(datas[index]!)),
    );
  }
}
