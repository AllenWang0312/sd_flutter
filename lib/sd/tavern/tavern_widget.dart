import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/android.dart';
import 'package:sd/sd/AIPainterModel.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/widget/AgeLevelCover.dart';

import '../../common/third_util.dart';
import '../../common/ui_util.dart';
import '../../common/util/file_util.dart';
import '../../common/util/string_util.dart';
import '../http_service.dart';
import '../platform.dart';
import 'bean/LocalFileInfo.dart';

List<LocalFileInfo> downloadRoot = [
  LocalFileInfo(
      name: 'huggingface.co', isDir: true, url: 'https://huggingface.co'),
  LocalFileInfo(name: 'civitai.com', isDir: true, url: 'https://civitai.com'),
  LocalFileInfo(
      name: 'aibooru.online', isDir: true, url: 'https://aibooru.online'),
  LocalFileInfo(name: 'pixai.art', isDir: true, url: 'https://pixai.art'),
  LocalFileInfo(name: 'finding.art', isDir: true, url: 'https://finding.art'),
  LocalFileInfo(
      name: 'aigodlike.com', isDir: true, url: 'https://www.aigodlike.com'),
  LocalFileInfo(name: 'lexica.art', isDir: true, url: 'https://lexica.art'),
  LocalFileInfo(
      name: 'search.krea.ai', isDir: true, url: 'https://search.krea.ai'),
];
List<String> promptHelper = [
  'http://wolfchen.top/tag/',
  'https://www.prompttool.com/NovelAI',
];

class TavernWidget extends StatefulWidget {
  @override
  State<TavernWidget> createState() => _TavernWidgetState();
}

class _TavernWidgetState extends State<TavernWidget> {
  String TAG = "TavernWidget";
  Directory? dir;

  List<LocalFileInfo> currentDir = [];
  List<List<LocalFileInfo>> stacks = [];
  List<double> offsets = [];

  int editModel = 0; // 1 pick 2 cut 3 copy
  Set<LocalFileInfo> checkedFiles = Set();
  Set<LocalFileInfo> cutFiles = Set();

  late AIPainterModel provider;

  @override
  void initState() {
    super.initState();
    initData(false);
  }

  // todo 编辑相关操作会闪烁  使用provider 优化/
  void initData(bool refresh) {
    stacks.clear();
    currentDir.clear();

    currentDir.addAll(downloadRoot);
    currentDir.addAll(getDirFiles(Directory(ANDROID_DOWNLOAD_DIR)));

    stacks.add(currentDir);
    if (refresh) {
      setState(() {});
    }
  }

  late ScrollController controller;

  @override
  Widget build(BuildContext context) {
    controller = ScrollController(keepScrollOffset: false);

    provider = Provider.of<AIPainterModel>(context, listen: false);
    return WillPopScope(
        onWillPop: () async {
          if (editModel != 0) {
            setState(() {
              cutFiles.clear();
              checkedFiles.clear();
              editModel = 0;
            });
            return false;
          } else if (stacks.length > 1) {
            stacks.removeLast();
            double offset = offsets.removeLast();
            controller.jumpTo(offset);
            setState(() {
              dir = dir?.parent;
              currentDir = stacks.last;
            });
            return false;
          }
          return true;
        },
        child: Column(
          children: [
            AppBar(
              centerTitle: true,
              title: Text('Tavern'),
              actions: [
                Offstage(
                  offstage: editModel != 1,
                  child: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      // showEditDialog(context);
                      setState(() {
                        editModel = 3;
                      });
                    },
                  ),
                ),
                Offstage(
                  offstage: editModel != 1,
                  child: IconButton(
                    icon: Icon(Icons.cut),
                    onPressed: () {
                      // showEditDialog(context);
                      cutFiles.addAll(checkedFiles);
                      checkedFiles.clear();
                      setState(() {
                        editModel = 2;
                      });
                    },
                  ),
                ),
                Offstage(
                  offstage: editModel != 2 && editModel != 3,
                  child: Badge(
                    label: Text(
                        '${editModel == 2 ? cutFiles.length : checkedFiles.length}'),
                    child: IconButton(
                        onPressed: () {
                          if (editModel == 2) {
                            for (var e in cutFiles) {
                              e.file.copySync('${dir?.path}/${e.name}');
                              e.file.deleteSync();
                            }
                          } else {
                            for (var e in checkedFiles) {
                              e.file.copySync('${dir?.path}/${e.name}');
                            }
                          }
                          setState(() {
                            //刷新当前目录
                            if (null != dir) {
                              stacks.removeLast();
                              currentDir.clear();
                              currentDir.addAll(getDirFiles(dir!));
                              stacks.add(currentDir);
                            }

                            cutFiles.clear();
                            checkedFiles.clear();
                            editModel = 0;
                            // initData(true);
                          });
                        },
                        icon: Icon(Icons.paste)),
                  ),
                )
              ],
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // mainAxisSpacing: 10,
                    // crossAxisSpacing: 10,
                    childAspectRatio: 512 / 768),
                controller: controller,
                children: currentDir
                    .map((e) => e.isDir
                        ? dirContent(e)
                        : fileBody(currentDir, currentDir.indexOf(e), e))
                    .toList(),
              ),
            )
          ],
        ));
  }

  Widget fileBody(List<LocalFileInfo> files, int index, LocalFileInfo info) {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
              onLongPress: () {
                logt(TAG, 'onLongPress');
                setState(() {
                  editModel = 1;
                });
              },
              onTap: () {
                if (editModel == 1) {
                  setState(() {
                    if (checkedFiles.contains(info)) {
                      checkedFiles.remove(info);
                    } else {
                      checkedFiles.add(info);
                    }
                  });
                } else {
                  Navigator.pushNamed(context, ROUTE_IMAGES_VIEWER, arguments: {
                    "urls": files,
                    "index": index,
                    "scanAvailable": provider.sdServiceAvailable
                  });
                }
              },
              child: AgeLevelCover(info)),
        ),
        // Positioned(
        //   bottom: 0,
        //   child: Text(
        //     info.name!,
        //     softWrap: true,
        //     overflow: TextOverflow.ellipsis,
        //     maxLines: 1,
        //   ),
        // ),
        Offstage(
          offstage: editModel != 1,
          child: Checkbox(
              value: checkedFiles.contains(info),
              onChanged: (value) {
                if (value!) {
                  checkedFiles.add(info);
                } else {
                  checkedFiles.remove(info);
                }
              }),
        ),
      ],
    );
  }

  Widget dirContent(LocalFileInfo info) {
    int? count = info.fileCount;
    return InkWell(
      onTap: () {
        if (info.isExist) {
          if (count != null && count > 0) {
            setState(() {
              dir = Directory(info.getLocalPath());
              currentDir = info.images!;
              offsets.add(controller.offset);
              controller.jumpTo(0);
              stacks.add(currentDir);
            });
          } else {
            // platform
            //     .invokeMethod('android.intent.action.VIEW', {"url": info.url});

            Navigator.pushNamed(context, ROUTE_WEBVIEW, arguments: {
              "title": info.name,
              "url": info.dirDes,
              "savePath": info.localPath
            });
          }
        } else {
          setState(() {
            Directory(info.getLocalPath()).createSync(recursive: true);
          });
          if (null != info.dirDes && !File(info.iconFilePath).existsSync()) {
            saveUrlToLocal(
                "${info.dirDes!}/favicon.ico", 'favicon.ico', info.getLocalPath());
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          info.cover != null
              ? AgeLevelCover(info.cover!, needInfoLogo: false)
              : Container(),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: GestureDetector(
              onLongPressStart: (detail) {
                PopupMenuItem entry = PopupMenuItem(
                  value: info.dirDes,
                  child: const Wrap(
                      children: [Text('使用本地浏览器打开'), Icon(Icons.open_in_new)]),
                );
                RelativeRect position = RelativeRect.fromLTRB(
                    detail.globalPosition.dx,
                    detail.globalPosition.dy,
                    double.infinity,
                    double.infinity);
                showMenu(
                        context: context,
                        items: [
                          entry,
                        ],
                        position: position)
                    .then((value) {
                  platform.invokeMethod(
                      'android.intent.action.VIEW', {"url": value});
                });
              },
              // onLongPress: (){
// }
              onTap: () {
                Navigator.pushNamed(context, ROUTE_WEBVIEW, arguments: {
                  "title": info.name,
                  "url": info.dirDes,
                  "savePath": info.localPath
                });
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                FutureBuilder(
                    future: getSvgData(info),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          width: 24,
                          height: 24,
                        );
                      } else {
                        return myPlaceholder(24, 24);
                      }
                    }),
                Text(
                  info.isExist ? info.name! : "${info.name!}(未创建)",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<LocalFileInfo> getDirFiles(Directory dir) {
    return dir.listSync().where((element) {
      return element.path.contains('.') &&
          SUPPORT_IMAGE_TYPES.contains(getFileExt(element.path));
    }).map((e) {
      return LocalFileInfo(name: getFileName(e.path), absPath: e.path);
    }).toList();
  }

  Future<Uint8List> getSvgData(LocalFileInfo info) async {
    File iconFile = File(info.iconFilePath);
    if (await iconFile.exists()) {
      return iconFile.readAsBytes();
    } else {
      Uint8List remote = await getBytesWithDio("${info.dirDes}/favicon.ico");
      await iconFile.create(exclusive: true, recursive: true);
      await iconFile.writeAsBytes(remote);
      return remote;
    }
  }
}
