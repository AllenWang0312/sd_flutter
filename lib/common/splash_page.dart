import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sd/bean/PromptStyle.dart';
import '../sd/config.dart';
import '../sd/http_service.dart';
import '../sd/model/AIPainterModel.dart';

const int SPLASH_WATTING_TIME = 3;

class SplashPage extends StatelessWidget {
  static const String TAG = "SplashPage";
  late SharedPreferences sp;
  bool canSkip = false;
  int getSettingSuccess = 0;

  late AIPainterModel provider;
  Timer? _countdownTimer;

  @override
  Widget build(BuildContext context) {
    logt(TAG, 'build');
    provider = Provider.of<AIPainterModel>(context, listen: false);
    provider.load();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (provider.countdownNum <= 0) {
        jumpAndCancelTimerIfSettingIsReady(context, null);
      }
      if (provider.countdownNum == 1) {
        getSettings();
      }
      provider.countDown();
    });
    // String _cover =
    //     'https://img-md.veimg.cn/meadincms/img1/21/2021/0119/1703252.jpg';

    // String _cover = 'http://$sdHost:$SD_PORT/static/img/api-logo.svg';
    return Scaffold(
      body: Selector<AIPainterModel, String>(
        selector: (_, model) => model.splashImg,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, newValue, child) {
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
                      // child: InkWell(
                      //   onTap: () {
                      //     _countdownTimer?.cancel();
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //       return WebViewPage('更多',_clickUrl);
                      //     }));
                      //   },
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: newValue,
                        // placeholder: (context, url) =>
                        //     Image.asset('images/splash_bg.png'),
                      ),
                      // ),
                    ),
                    child!
                  ],
                );
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

  // void getBanner() async {
  //   await get(context, 'getBannerData').then((snapshot) {
  //     var value = json.decode(snapshot.toString());
  //     String newUrl = value['data'][0]['imageurl'];
  //     _clickUrl = value['data'][0]['linkurl'];
  //     if (newUrl != _cover) {
  //       setState(() {
  //         _cover = newUrl;
  //       });
  //     }
  //   });
  // }

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

  void getSettings() async {
    printDir(await getTemporaryDirectory());
    printDir(await getApplicationSupportDirectory());
    printDir(await getApplicationDocumentsDirectory());

    // printDir(await getExternalStorageDirectory());  //only for android
    // printDirs(await getExternalCacheDirectories()); // only for android
    // printDirs(await getExternalStorageDirectories()); //only for android
    // printDir(await getDownloadsDirectory()); //only for not android

    // if(provider.workspace)

    if (null != provider.selectWorkspace?.stylesConfigFilePath &&
        provider.selectWorkspace!.stylesConfigFilePath!.isNotEmpty) {
      String myData =
          await File(provider.selectWorkspace!.stylesConfigFilePath!)
              .readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
      List<dynamic> colums = csvTable.removeAt(0);
      int nameIndex = colums.indexOf(PromptStyle.NAME);
      int typeIndex = colums.indexOf(PromptStyle.TYPE);
      int promptIndex = colums.indexOf(PromptStyle.PROMPT);
      int negPromptIndex = colums.indexOf(PromptStyle.NEG_PROMPT);

      provider.styles = csvTable
          .map((e) => PromptStyle(
              name: e[nameIndex],
              type: e[typeIndex],
              prompt: e[promptIndex],
              negativePrompt: e[negPromptIndex]))
          .toList();
      logt(TAG, csvTable.toString());
    } else {
      get("$sdHttpService$GET_STYLES").then((value) {
        List re = value?.data as List;
        provider.styles = re.map((e) => PromptStyle.fromJson(e)).toList();
      });
    }

    // get("$sdHttpService$RUN_PREDICT", exceptionCallback: (e) {
    //   getSettingSuccess = -1;
    // }).then((value) {
    //   // Options op = Options.fromJson(value.data);
    //   String modelName = value?.data['sd_model_checkpoint'];
    //   provider
    //       .updateSDModel(modelName.substring(0, modelName.lastIndexOf('.')));
    //   getSettingSuccess = 1;
    // });
    get("$sdHttpService$GET_OPTIONS", exceptionCallback: (e) {
      getSettingSuccess = -1;
    }).then((value) {
      // Options op = Options.fromJson(value.data);
      String modelName = value?.data['sd_model_checkpoint'];
      provider.updateSDModel(modelName);
      getSettingSuccess = 1;
    });
  }

  // void tokenLogin() async {
  //   sp ??= await SharedPreferences.getInstance();
  //   String token = sp?.getString("token") ?? "";
  //   if (kDebugMode) {
  //     print('token ${token}');
  //   }
  //   if (token.isNotEmpty) {
  //     context.read<LoginStateProvider>().loginSuccess(token);
  //     await post(context, 'tokenLogin', formData: {"user_ticket": token})
  //         .then((snapshot) {
  //       // if(hasError( context,snapshot)){
  //       // }else{
  //       context.read<LoginStateProvider>().loginSuccess(token);
  //       // }
  //       reSetCountdown();
  //     });
  //   } else {
  //     reSetCountdown();
  //   }
  // }

  // String _token = "";
  //
  // Future<String?> get token async {
  //   if (_token.isEmpty) {
  //     sp ??= await SharedPreferences.getInstance();
  //     _token = sp?.getString("token") ?? "";
  //   }
  //   return _token;
  // }
  // ignore: use_build_context_synchronously
  void jumpAndCancelTimerIfSettingIsReady(BuildContext context, String? token) {
    if (getSettingSuccess != 0) {
      if (_countdownTimer != null) {
        _countdownTimer!.cancel();
      }
      // if (null!=token&&token.isNotEmpty) {
      // ignore: use_build_context_synchronously

      Navigator.popAndPushNamed(context, ROUTE_HOME);

      // } else {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return LoginPage(
      //       fromMain: false,
      //     );
      //   }));
      // }
    }
  }
}
