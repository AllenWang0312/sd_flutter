import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/platform/platform.dart';
import 'package:sd/sd/bean/db/LocalFileInfo.dart';
import 'package:sd/sd/bean/file/Showable.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';

import '../../../common/third_util.dart';
import '../../bean/file/UniqueSign.dart';
import '../../const/config.dart';
import '../../http_service.dart';
import '../../mocker.dart';
import '../../widget/age_level_cover.dart';
import '../../widget/file_prompt_reader.dart';
import '../home/txt2img/tagger_widget.dart';
import 'ImagesModel.dart';

const String TAG = "ImageViewer";

class ExtInfo {
  String? prompts;
  String? remoteFilePath;
  bool favourite = true;
}

enum ImagesType {
  datas,
  urls,
  files,
}

class SDImagesViewer<T extends UniqueSign> extends StatelessWidget {
  int? pageSize;
  int? pageNum;
  int? index;
  String? title;

  // late Function? loadMore;
  List<T>? urls;
  List<Uint8List?> datas = [];

  String? relativeSaveDirPath;
  bool scanServiceAvailable;

  bool? isFavourite;
  String? type;
  int fnIndex; //remote +3 fav-10 del -12
  int? autoCancel;

  late ImagesType dataType;

  SDImagesViewer(
      {this.autoCancel,
      this.urls,
      this.index,
      this.fnIndex = 0,
      this.title,
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
  Timer? countdownTimer;
  @override
  Widget build(BuildContext context) {
    if (autoCancel != null && autoCancel! > 0) {
      countdownTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (autoCancel! <= 0) {
          Navigator.pop(context);
          countdownTimer?.cancel();
          countdownTimer = null;
        }
        autoCancel = autoCancel! - 1;
      });
    }
    provider = Provider.of<AIPainterModel>(context, listen: false);
    images = Provider.of<ImagesModel>(context, listen: false);

    images.initExts(this.datas.length);

    PageController controller = PageController(initialPage: index ?? 0);
    if (null != urls) {
      onPageChange(index ?? 0);
    }

    return Stack(
      children: [
        _pageView(controller),
        SafeArea(child: _appBar(context, controller)),
        // Positioned(
        //   left: 0,
        //   right: 0,
        //   bottom: 0,
        //   child: Selector<ImagesModel, int>(
        //     selector: (_, model) => model.index,
        //     builder: (context, value, child) {
        //       return Text('${(value + 1).toString()}/${datas.length}');
        //     },
        //   )

        //               TextButton(
//                   onPressed: () async {
//                     var width = MediaQuery.of(context).size.width;
//                     var height = MediaQuery.of(context).size.height;
// //             await Wallpaper.homeScreen(
// //                 options: RequestSizeOptions.RESIZE_FIT,
// //                 width: width,
// //                 height: height);
// //             print("Task Done");
//                   },
//                   child: Text('设为壁纸'))

        // ),
      ],
    );
  }

  onPageChange(int page) async {
    Showable item = urls![page];
    if (null != type && item.getFileLocation().startsWith("http")) {
      images.updateIndex(page);
      String? currentRemotePath = images.exts[page]?.remoteFilePath;
      if (null == currentRemotePath) {
        await post("$sdHttpService$RUN_PREDICT",
                formData: getRemoteHistoryInfo(
                    fnIndex + 3, page % 36, page ~/ 36 + 1, type!))
            .then((value) {
          String currentRemoteFilePath = value!.data?['data'][0];
          images.updateRemoteFilePath(page, currentRemoteFilePath);
          // images.currentRemoteFilePath(value!.data?['data'][0]);
          logt(TAG, "get Remote Info $currentRemoteFilePath");
        });
      }
    } else if (null != urls) {
      images.updateCurrentDes(page, urls![page].exif);
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
    if (data is LocalFileInfo) {
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
        String sign = data.uniqueTag();
        int currentLevel = await provider.getAgeLevel(sign);

        RelativeRect position = RelativeRect.fromLTRB(detail.globalPosition.dx,
            detail.globalPosition.dy, double.infinity, double.infinity);
        if (context.mounted) {
          showMenu(context: context, position: position, items: [
            if ((dataType == ImagesType.urls &&
                    images.exts[index]?.remoteFilePath != null) ||
                dataType == ImagesType.files)
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
                  provider.setAgeLevel(data.uniqueTag(), value);
                }
              } else {
                if (await DBController.instance
                        .insertAgeLevelRecord(data, datas[index], value) >
                    0) {
                  provider.setAgeLevel(sign, value);
                }
              }
            } else if (value == -100) {
              if (dataType == ImagesType.urls) {
                post("$sdHttpService$RUN_PREDICT",
                        formData: delateFile(
                            fnIndex - 12,
                            images.exts[index]?.remoteFilePath,
                            index ~/ 36 + 1,
                            index % 36,
                            36))
                    .then((value) {
                  logt(TAG, "delete file$value");

                  urls?.removeAt(index);
                  images.removeExtsAt(index);
                  removedItems ??= [];
                  removedItems?.add(data.getFileLocation());
                  onPageChange(index);
                });
              } else {
                String? localPath = urls?[index].getFileLocation();
                if (null != localPath) {
                  int result =
                      await DBController.instance.deleteLocalRecord(localPath);
                  if (result > 0) {
                    File(localPath).deleteSync(recursive: true);
                  }
                  logt(TAG, "delete result $result $localPath");
                }
              }
            } else {
              if (await DBController.instance
                      .removetAgeLevelRecord(data, datas[index]) >
                  0) {
                provider.setAgeLevel(sign, 0);
              }
            }
          });
        }
      },
      child: _heroWapper(data.getFileLocation(), index),
    );
  }

  Widget _appBar(BuildContext context, PageController controller) {
    return SizedBox(
      height: 48,
      child: AppBar(
        centerTitle: true,
        title: Text('${title ?? ''}'),
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
          Selector<ImagesModel, int>(
            selector: (_, model) => model.index,
            builder: (context, value, child) {
              ExtInfo? info = images.exts[value];
              return Offstage(
                  offstage: true == isFavourite || info == null,
                  child: IconButton(
                    icon: Icon(info!.favourite
                        ? Icons.favorite_outlined
                        : Icons.favorite_border),
                    onPressed: () async {
                      if (info.favourite) {
                        Fluttertoast.showToast(msg: '暂不支持取消');
                      } else {
                        int? page = controller.page?.toInt();
                        if (null != page) {
                          String? remoteFilePath =
                              images.exts[page]?.remoteFilePath;
                          if (null != remoteFilePath) {
                            await post("$sdHttpService$RUN_PREDICT",
                                    formData: addToFavourite(
                                        fnIndex - 10, remoteFilePath))
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
                        asyncPath??"" + relativeSaveDirPath!);
                    Fluttertoast.showToast(msg: result.toString());
                  } else {
                    dynamic result = await saveUrlToLocal(
                        urls![controller.page!.toInt()].getFileLocation(),
                        "${DateTime.now()}.png",
                        asyncPath??"" + relativeSaveDirPath!);
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
                    await syncTagger(cmd.getImageTaggers, bytes,
                        provider.selectedInterrogator, 30, (tagger) {
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
        ],
      ),
    );
  }

  Widget _pageView(PageController controller) {
    return null == urls
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
          );
  }

  bool get isRemote {
    return dataType == ImagesType.urls;
  }

  _heroWapper(String fileLocation, int index) {
    return Hero(
        tag: isRemote ? fileLocation : index,
        child: interactiveView(isRemote
            ? CachedNetworkImage(imageUrl: fileLocation)
            : dataType == ImagesType.files
                ? Image.file(File(fileLocation))
                : Image.memory(datas[index]!)));
  }
}
