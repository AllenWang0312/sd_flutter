import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/android.dart';
import 'package:sd/common/util/ui_util.dart';
import 'package:sd/sd/AIPainterModel.dart';
import 'package:sd/sd/HomeModel.dart';
import 'package:sd/sd/config.dart';
import 'package:sd/sd/tavern/bean/ImageSize.dart';

import '../../common/third_util.dart';
import '../../common/ui_util.dart';
import '../../common/util/file_util.dart';
import '../../common/util/string_util.dart';
import '../bean/Configs.dart';
import '../http_service.dart';
import '../platform.dart';
import 'bean/FileInfo.dart';

List<FileInfo> downloadRoot = [
  FileInfo(name: 'huggingface.co', isDir: true, url: 'https://huggingface.co'),
  FileInfo(name: 'civitai.com', isDir: true, url: 'https://civitai.com'),
  FileInfo(name: 'aibooru.online', isDir: true, url: 'https://aibooru.online'),
  FileInfo(name: 'pixai.art', isDir: true, url: 'https://pixai.art'),
  FileInfo(name: 'finding.art', isDir: true, url: 'https://finding.art'),
  FileInfo(
      name: 'aigodlike.com', isDir: true, url: 'https://www.aigodlike.com'),
  FileInfo(name: 'lexica.art', isDir: true, url: 'https://lexica.art'),
  FileInfo(name: 'search.krea.ai', isDir: true, url: 'https://search.krea.ai'),
];
List<String> promptHelper = [
  'http://wolfchen.top/tag/',
  'https://www.prompttool.com/NovelAI',
];

class TavernWidget extends StatefulWidget {
  @override
  State<TavernWidget> createState() => _TavernWidgetState();
}

class _TavernWidgetState extends State<TavernWidget>
    with WidgetsBindingObserver {
  String TAG = "TavernWidget";
  Directory? dir;

  List<FileInfo> currentDir = [];
  List<List<FileInfo>> stacks = [];
  List<double> offsets = [];

  int editModel = 0; // 1 pick 2 cut 3 copy
  Set<FileInfo> checkedFiles = Set();
  Set<FileInfo> cutFiles = Set();

  late AIPainterModel provider;
  late HomeModel home;
  final LocalAuthentication auth = LocalAuthentication();
  bool canAuthenticateWithBiometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    init();
    initData(false);
  }

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
    home = Provider.of<HomeModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
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
      body: WillPopScope(
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
      ),
    );
  }

  Widget fileBody(List<FileInfo> files, int index, FileInfo info) {
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
              child: ageLevelCover(info)),
        ),
        Positioned(
          bottom: 0,
          child: Text(
            info.name!,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
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

  Widget ageLevelCover(FileInfo info, {bool? needInfoLogo = true}) {
    File image = File(info.getLocalPath());
    Uint8List bytes = image.readAsBytesSync();
    Image img = Image.memory(bytes);

    // String sign = info.getSign(bytes);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: SHAPE_IMAGE_CARD,
      child: FutureBuilder(
        future: info.getExif(image),
        builder: (context, snapshot) {
          return Stack(
            children: [
              Selector<AIPainterModel, int>(
                selector: (_, model) =>
                    provider.hideNSFW ? info.getAgeLevel(provider, bytes) : 0,
                builder: (context, value, child) {
                  return value >= 18
                      ? ImageFiltered(imageFilter: AGE_LEVEL_BLUR, child: child)
                      : child!;
                },
                child: Selector<AIPainterModel, ImageSize?>(
                  selector: (_, model) => model.imgSize[info.sign],
                  builder: (context, value, child) {
                    return img;
                  },
                ),
              ),
              if (null != snapshot.data &&
                  snapshot.data!.isNotEmpty &&
                  null != needInfoLogo &&
                  needInfoLogo)
                Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () async {
                        int result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Prompt'),
                                content: SingleChildScrollView(
                                    child: SelectableText(
                                        snapshot.data.toString())),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        provider.updateConfigs(
                                            Configs.fromString(
                                                snapshot.data.toString()));
                                        Navigator.of(context).pop(2);
                                      },
                                      child: Text('立即使用')),
                                  TextButton(
                                      onPressed: () {}, child: Text('复制'))
                                ],
                              );
                            });
                        home.updateIndex(result);
                      },
                      icon: const Icon(Icons.info),
                    ))
            ],
          );
        },
      ),
    );
  }

  Widget dirContent(FileInfo info) {
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
              "url": info.url,
              "savePath": info.localPath
            });
          }
        } else {
          setState(() {
            Directory(info.getLocalPath()).createSync(recursive: true);
          });
          if (null != info.url && !File(info.iconFilePath).existsSync()) {
            saveUrlToLocal(
                "${info.url!}/favicon.ico", 'favicon.ico', info.getLocalPath());
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          info.cover != null
              ? ageLevelCover(info.cover!, needInfoLogo: false)
              : Container(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onLongPressStart: (detail) {
                PopupMenuItem entry = PopupMenuItem(
                  value: info.url,
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
                  "url": info.url,
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
                        return myPlaceholder( 24, 24);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      logt(TAG, "resumed");
      initData(true);
    } else if (state == AppLifecycleState.inactive) {
      logt(TAG, "inactive");
      if (provider.checkIdentityWhenReEnter &&
          availableBiometrics != null &&
          availableBiometrics!.isNotEmpty) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return BackdropFilter(
                filter: CHECK_IDENTITY,
                child: AlertDialog(
                  title: Text('身份认证'),
                  content: Text('您是本机的主人吗'),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          try {
                            final bool didAuthenticate =
                            await auth.authenticate(
                                localizedReason: '应用开启离开认证 需要验证您的身份',
                                options: const AuthenticationOptions(
                                    biometricOnly: true));

                            if (didAuthenticate) {
                              Navigator.pop(context);
                            }
                          } on PlatformException catch (e) {
                            if (e.code == auth_error.notEnrolled) {
                            } else if (e.code == auth_error.lockedOut ||
                                e.code == auth_error.permanentlyLockedOut) {
                            } else {}
                          }
                        },
                        child: Text('开始识别'))
                  ],
                ),
              );
            });
      }

    } else if (state == AppLifecycleState.paused) {
      logt(TAG, "paused");
    } else if (state == AppLifecycleState.detached) {
      logt(TAG, "detached");
    }
  }

  Iterable<FileInfo> getDirFiles(Directory dir) {
    return dir.listSync().where((element) {
      return element.path.contains('.') &&
          SUPPORT_IMAGE_TYPES.contains(getFileExt(element.path));
    }).map((e) {
      return FileInfo(name: getFileName(e.path), absPath: e.path);
    }).toList();
  }

  Future<Uint8List> getSvgData(FileInfo info) async {
    File iconFile = File(info.iconFilePath);
    if (await iconFile.exists()) {
      return iconFile.readAsBytes();
    } else {
      Uint8List remote = await getBytesWithDio("${info.url}/favicon.ico");
      await iconFile.create(exclusive: true, recursive: true);
      await iconFile.writeAsBytes(remote);
      return remote;
    }
  }

  late List<BiometricType>? availableBiometrics;

  Future<void> init() async {
    canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (canAuthenticate)
      availableBiometrics = await auth.getAvailableBiometrics();
    // if (availableBiometrics.contains(BiometricType.strong) ||
    //     availableBiometrics.contains(BiometricType.face)) {
    //   // Specific types of biometrics are available.
    //   // Use checks like this with caution!
    // }
  }
}
