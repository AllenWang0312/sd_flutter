import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';

import 'android.dart';
import '../sd/bean/PromptStyle.dart';
import '../sd/config.dart';
import '../sd/http_service.dart';
import '../sd/AIPainterModel.dart';

const int SPLASH_WATTING_TIME = 3;

Future<List<PromptStyle>> loadPromptStyleFromCSVFile(String csvFilePath) async {
  String myData = await File(csvFilePath).readAsString();
  List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
  List<dynamic> colums = csvTable.removeAt(0);
  int nameIndex = colums.indexOf(PromptStyle.NAME);
  int typeIndex = colums.indexOf(PromptStyle.TYPE);
  int promptIndex = colums.indexOf(PromptStyle.PROMPT);
  int negPromptIndex = colums.indexOf(PromptStyle.NEG_PROMPT);
  return csvTable
      .map((e) => PromptStyle(
          name: e[nameIndex],
          type: e[typeIndex],
          prompt: e[promptIndex],
          negativePrompt: e[negPromptIndex]))
      .toList();
}

class SplashPage extends StatelessWidget {
  static const String TAG = "SplashPage";
  late SharedPreferences sp;
  bool canSkip = false;
  int? getSettingSuccess;

  late AIPainterModel provider;
  Timer? _countdownTimer;

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isAndroid) {
      createDirIfNotExit(ANDROID_APP_DOWNLOAD_DIR);
    }
    logt(TAG, 'build');
    provider = Provider.of<AIPainterModel>(context, listen: false);
    provider.load();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (provider.countdownNum <= 0) {
        jumpAndCancelTimerIfSettingIsReady(context, null);
      }
      if (provider.countdownNum == 1) {
        getSettings();
      }
      provider.countDown();
    });

    return Scaffold(
      body: Selector<AIPainterModel, String?>(
        selector: (_, model) => model.splashImg,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, newValue, child) {
          if(null!=newValue){
            return newValue.endsWith('.svg') | newValue.endsWith('.ico')
                ? Center(
                child: SvgPicture.network(
                  newValue,
                  width: 80,
                  height: 80,
                ))
                : Stack(
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: newValue,
                  ),
                  // ),
                ),
                child!
              ],
            );
          }else{
            return Container();
          }
        },
        child: Align(
            alignment: Alignment.bottomRight,
            child: SafeArea(
              minimum: const EdgeInsets.all(12),
              child: Visibility(
                visible: canSkip,
                child: InkWell(
                  onTap: () {
                    // jump(token.toString());
                    jumpAndCancelTimerIfSettingIsReady(context, null);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(
                        minWidth: 24, maxHeight: 24, maxWidth: 64),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Selector<AIPainterModel, int>(
                      selector: (_, model) => model.countdownNum,
                      shouldRebuild: (pre, next) => pre != next && next != 0,
                      builder: (context, newValue, child) {
                        return Text(
                          '跳过(${newValue >= 0 ? newValue : 0}s)',
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  void getSettings() async {
    printDir(
        await getTemporaryDirectory()); // /data/user/0/edu.tjrac.swant.sd/cache
    printDir(
        await getApplicationSupportDirectory()); // /data/user/0/edu.tjrac.swant.sd/files
    printDir(
        await getApplicationDocumentsDirectory()); // /data/user/0/edu.tjrac.swant.sd/app_flutter
    // printDir(await getExternalStorageDirectory());  //only for android
    // printDirs(await getExternalCacheDirectories()); // only for android
    // printDirs(await getExternalStorageDirectories()); //only for android
    // printDir(await getDownloadsDirectory()); //only for not android

    // if(provider.workspace)
    // get("$sdHttpService$RUN_PREDICT", exceptionCallback: (e) {
    //   getSettingSuccess = -1;
    // }).then((value) {
    //   // Options op = Options.fromJson(value.data);
    //   String modelName = value?.data['sd_model_checkpoint'];
    //   provider
    //       .updateSDModel(modelName.substring(0, modelName.lastIndexOf('.')));
    //   getSettingSuccess = 1;
    // });
    get("$sdHttpService$GET_OPTIONS", timeOutSecond: 10,
        exceptionCallback: (e) {
      getSettingSuccess = -1;
    }).then((value) {
      // Options op = Options.fromJson(value.data);
      String modelName = value?.data['sd_model_checkpoint'];
      remoteTXT2IMGDir = value?.data['outdir_txt2img_samples'];
      provider.sdServiceAvailable = true;
      provider.updateSDModel(modelName);
      getSettingSuccess = 1;
    });
  }

  printDir(Directory? dir) {
    if (null != dir) {
      logt(TAG, "download path" + dir.path.toString());
    }
  }

  printDirs(List<Directory>? dirs) {
    if (null != dirs) {
      logt(TAG, "print path:" + dirs.toString());
    }
  }

  void jumpAndCancelTimerIfSettingIsReady(BuildContext context, String? token) {
    if (getSettingSuccess != null && getSettingSuccess != 0) {
      if (_countdownTimer != null) {
        _countdownTimer!.cancel();
      }
      if(context.mounted){
        Navigator.popAndPushNamed(context, ROUTE_HOME);
      }
    }
  }
}
