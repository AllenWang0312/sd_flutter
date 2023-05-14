import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/bean4json/GenerateProgress.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/mocker.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/pages/home/txt2img/TXT2IMGModel.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/widget/LifecycleState.dart';

const String TAG = "GenerateButton";

class GenerateButton extends StatefulWidget {
  Function()? onPressed;

  GenerateButton(this.onPressed);

  @override
  State<StatefulWidget> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends LifecycleState<GenerateButton> {
  int countDown = 0;
  int id_live_preview = 0;
  String taskId = '';
  bool isActive = true;

  Timer? _countdownTimer;

  // int nextCheckTime = 10;

  late AIPainterModel provider;

  bool backgroundProgress =
      true; //todo 接口错误 暂时关闭 状态同步 后台10s 检查progress 或者请求时 主动1s检查 progress

  @override
  Widget build(BuildContext context) {
    TXT2IMGModel model = Provider.of<TXT2IMGModel>(context, listen: false);
    provider = Provider.of<AIPainterModel>(context, listen: false);
    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (isActive && provider.netWorkState > 0) {
        if (!backgroundProgress) {
          //前台
          // nextCheckTime = 10;
          if (id_live_preview == 0) {
            taskId = randomStr(15);
          }
          countDown = 0;
          post("$sdHttpService$GET_PROGRESS",
                  formData: getPreview(id_live_preview, taskId),
                  exceptionCallback: (e) {})
              .then((value) {
            if (null != value) {
              GenerateProgress progress = GenerateProgress.fromJson(value.data);
              logt(TAG, "forground progress $progress");
              forgroundProgressCheck(progress, model);
            }
          });
        } else {
          // countDown ++;
          // if(countDown%2==0){
          //   post("$sdHttpService$GET_PROGRESS",formData: getPreview(id_live_preview,taskId), exceptionCallback: (e) {
          //     countDown = 0;
          //   }).then((value) {
          //     if (null != value) {
          //       GenerateProgress progress = GenerateProgress.fromJson(value.data);
          //       logt(TAG,"background progress $progress");
          //       backgroundProgressCheck(progress,model);
          //     }
          //   });
          // }
        }
      }
    });
    // Selector<TXT2IMGModel, Uint8List?>(
    //   builder: (_, newValue, child) =>
    //   newValue == null ? Container() : Image.memory(newValue),
    //   selector: (_, model) => model.previewData,
    //   shouldRebuild: (pre, next) => !(next == null && pre == null),
    // )
    return Stack(children: [
      FloatingActionButton(
        onPressed: () {
          backgroundProgress = false;
          id_live_preview = 0;
          widget.onPressed!();
        },
        child: Text(AppLocalizations.of(context).generate),
      ),
      SizedBox(
        width: 56,
        height:56,
        child: Selector<AIPainterModel, int>(
            selector: (_, model) => model.netWorkState,
            shouldRebuild: (pre, next) => pre != next,
            builder: (context, newValue, child) {
              if (newValue == REQUESTING) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              } else {
                return Container();
              }
            }),
      )
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    isActive = state == AppLifecycleState.resumed;
  }

  void forgroundProgressCheck(GenerateProgress progress, TXT2IMGModel model) {
    id_live_preview = progress.idLivePreview!;
    model.updateProgress(progress.progress);
    if (progress.livePreview != null) {
      model.updatePreviewData(
          base64Decode(progress.livePreview!.substring(BASE64_PREFIX.length)));
    }
    if (
        // progress.progress==null
        progress.completed == true) {
      // provider.updateNetworkState(ONLINE);
      logd("timer cancel");
      // _countdownTimer?.cancel();
      backgroundProgress = true;
    } else {
      // provider.updateNetworkState(BUSY);
    }
  }

  void backgroundProgressCheck(GenerateProgress progress, TXT2IMGModel model) {
    if (progress.progress != null
        // null!=progress.completed&&!progress.completed!
        ) {
      provider.updateNetworkState(BUSY);
      logt(TAG, 'completed');
    } else {
      // provider.updateNetworkState(ONLINE);
    }
  }
}
