import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/const/routes.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sd/const/config.dart';
import '../sd/http_service.dart';
import '../sd/provider/AIPainterModel.dart';

const int SPLASH_WATTING_TIME = 5;

const String TAG = "SplashPage";

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late SharedPreferences sp;
  bool canSkip = false;
  int? getSettingSuccess;
  late AIPainterModel provider;
  Timer? _countdownTimer;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context, listen: false);
    provider.loadConfig();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (provider.countdownNum <= 0) {
        jumpAndCancelTimerIfSettingIsReady(context);
      }

      if (provider.countdownNum == SPLASH_WATTING_TIME - 2) {
        getSettings();
      }
      provider.countDown();
    });

    return Scaffold(
      body: Selector<AIPainterModel, String?>(
        selector: (_, model) => model.splashImg,
        shouldRebuild: (pre, next) => pre != next,
        builder: (_, newValue, child) {
          if (null != newValue) {
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
          } else {
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
                    jumpAndCancelTimerIfSettingIsReady(context);
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

   getSettings() {
    // provider.networkInitApiOptions();
    get("$sdHttpService$GET_OPTIONS", timeOutSecond: 10,
        exceptionCallback: (e) {
      getSettingSuccess = -1;
    }).then((value) async {
      if (null != value && null != value.data) {
        // logt(TAG, "get options${value?.data.toString() ?? ""}");
        // Options op = Options.fromJson(value.data);
        String? modelName = value.data['sd_model_checkpoint'];

        remoteTXT2IMGDir = value.data['outdir_txt2img_samples'];
        remoteIMG2IMGDir = value.data['outdir_img2img_samples'];
        remoteMoreDir = value.data['outdir_extras_samples'];
        remoteFavouriteDir = value.data['outdir_save'];

        serviceVersion = await provider.initServiceConfigIfServiceActive();
        provider.initPromptStyleIfServiceActive(userAge:provider.userInfo.age);
        provider.initTranlatesIfServiceActive();

        provider.netWorkState = ONLINE;
        provider.updateSDModel(modelName);
        getSettingSuccess = 1; //todo 最后发起的不一定最后完成
      }
    });
  }

  void jumpAndCancelTimerIfSettingIsReady(BuildContext context) {
    if (getSettingSuccess != null && getSettingSuccess != 0) {
      if (context.mounted) {
        Navigator.popAndPushNamed(context, ROUTE_HOME);
      }
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   dependOnInheritedWidgetOfExactType()
  // }

  @override
  void dispose() {
    if (_countdownTimer != null) {
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
    logt(TAG, "dispose");
    super.dispose();
  }
}
