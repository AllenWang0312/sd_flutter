import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/tavern/bean/UniqueSign.dart';
import 'package:sd/sd/db_controler.dart';
import 'package:sd/sd/roll/tagger_widget.dart';
import 'package:sd/sd/AIPainterModel.dart';

import '../../common/third_util.dart';
import '../tavern/bean/Showable.dart';
import '../http_service.dart';
import '../widget/AgeLevelCover.dart';

class ImagesModel with ChangeNotifier, DiagnosticableTreeMixin {
  String? currentDes;

  void updateCurrentDes(String? des) {
    currentDes = des;
    notifyListeners();
  }
}
enum ImagesType{
  datas,urls,files,
}
class ImagesViewer<T extends UniqueSign> extends StatelessWidget {
  final String TAG = "ImageViewer";
  int? pageSize;
  int? pageNum;
  int? index;

  late Function? loadMore;

  List<T>? urls;
  List<Uint8List?> datas =[];
  String? saveDirPath;
  bool scanServiceAvailable;
  late ImagesType dataType;


  ImagesViewer(
      {this.urls,
      this.index,
      this.loadMore,
        List<Uint8List>? datas,
      this.saveDirPath,
      this.scanServiceAvailable = false}){
    if(datas!=null){
      dataType = ImagesType.datas;
      this.datas.addAll(datas);
    }else {
      if(urls!=null){
        this.datas = List<Uint8List?>.filled(urls!.length, null);
        if(urls![0].getFileLocation().startsWith('http')){
          dataType = ImagesType.urls;
        }else{
          dataType = ImagesType.files;
        }
      }
    }
  }

  late AIPainterModel provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    ImagesModel images = Provider.of<ImagesModel>(context, listen: false);
    PageController controller = PageController(initialPage: index ?? 0);
    if (null != urls) {
      images.updateCurrentDes(urls![index ?? 0].getPrompts());

      controller.addListener(() {
        int? page = controller.page?.toInt();
        if (null != page) {
          images.updateCurrentDes(urls![page].getPrompts());
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        actions: [
          Selector<ImagesModel, String?>(
            selector: (_, model) => model.currentDes,
            builder: (context, value, child) {
              return Offstage(
                offstage: value == null || value.isEmpty,
                child: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: ()=> showPromptDialog(provider,context,value!),
                ),
              );
            },
          ),
          Offstage(
            offstage: !scanServiceAvailable,
            child: IconButton(
                onPressed: () async {
                  int? page = controller.page?.toInt();
                  if (null != page) {
                    Uint8List bytes = await getBytes(page);
                    await getImageTagger(bytes).then((value){
                      if (context.mounted) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Tagger"),
                                content: SelectableText(value),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: value));
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
                      }

                    });

                  }
                  // provider.
                },
                icon: const Icon(Icons.settings_overscan)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: urls != null && urls!.isNotEmpty
                  ? PageView.builder(
                      onPageChanged: (page) async {
                      },
                      controller: controller,
                      itemCount: urls!.length,
                      itemBuilder: (context, index) {
                        logt(TAG, "$index");

                        T data = urls![index];
                        // bool isRemote =
                        //     data.getFileLocation().startsWith("http");
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

                            RelativeRect position = RelativeRect.fromLTRB(
                                detail.globalPosition.dx,
                                detail.globalPosition.dy,
                                double.infinity,
                                double.infinity);
                            if(context.mounted){
                              showMenu(
                                  context: context,
                                  position: position,
                                  items: [
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
                                  if(currentLevel>0){
                                    if(await DBController.instance
                                        .updateAgeLevelRecord(data, datas[index],value)>0){
                                      data.setAgeLevel(provider,value);
                                    }
                                  }else{
                                   if(await DBController.instance
                                       .insertAgeLevelRecord(data, datas[index],value)>0){
                                     data.setAgeLevel(provider,value);
                                   }
                                  }

                                } else {
                                  if(await DBController.instance
                                      .removetAgeLevelRecord(data, datas[index])>0){
                                    data.setAgeLevel(provider,0);
                                  }
                                }
                              });
                            }
                          },
                          child: InteractiveViewer(
                              maxScale: 3,
                              minScale: 0.5,
                              child: dataType == ImagesType.urls
                                  ? CachedNetworkImage(
                                      imageUrl: (data.getFileLocation()))
                                  : Image.memory(datas[index]!)),
                        );
                      })
                  : PageView.builder(
                      onPageChanged: (page) async {
                      },
                      controller: controller,
                      itemCount: datas.length,
                      itemBuilder: (context, index) {
                        logt(TAG, index.toString());

                        return InteractiveViewer(
                            maxScale: 3,
                            minScale: 0.5,
                            child: Image.memory(datas[index]!));
                      }),
            ),
          ),
          Offstage(
            offstage: saveDirPath == null,
            child: TextButton(
              onPressed: () async {
                if (await checkStoragePermission()) {
                  logt(TAG, controller.page!.toInt().toString());
                  dynamic result = await saveUrlToLocal(
                      urls![controller.page!.toInt()].getFileLocation(),
                      "${DateTime.now()}.png",
                      saveDirPath!);
                  Fluttertoast.showToast(msg: result.toString());
                } else {
                  Fluttertoast.showToast(
                      msg: "请允许应用使用存储权限", gravity: ToastGravity.CENTER);
                }
              },
              child: const Text("save to file"),
            ),
          )
        ],
      ),
    );
  }

  PopupMenuItem itemMenu(int age) {
    return PopupMenuItem(
      value: age,
      child: Text('设置年龄分级:$age+'),
    );
  }

  Future<Uint8List> getBytes(int page) async {
    if (null!=datas&&page>=0&&page<datas.length&&datas[page] != null) {
      return datas[page]!;
    } else {
      T showable = urls![page];
      String url = showable.getFileLocation();
      Uint8List bytes;
      if (url.startsWith('http')) {
        bytes = await getBytesWithDio(url);
      } else {
        bytes =  File(url).readAsBytesSync();
      }
      datas![page] = bytes;
      return bytes;
    }
  }
}
