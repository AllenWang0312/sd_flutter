

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/widget/LifecycleState.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../provider/AIPainterModel.dart';
import '../bean4json/GenerateProgress.dart';
import '../const/config.dart';
import '../http_service.dart';
import '../mocker.dart';
import '../roll/NetWorkStateProvider.dart';
import '../roll/RollModel.dart';

const String TAG = "GenerateButton";
class GenerateButton extends StatefulWidget{
  Function()? onPressed;

  GenerateButton(this.onPressed);

  @override
  State<StatefulWidget> createState()=>_GenerateButtonState();

}

class _GenerateButtonState extends LifecycleState<GenerateButton>{

  int countDown = 0;
  int id_live_preview = -1;
  bool isActive = true;
  Timer? _countdownTimer;

  int nextCheckTime = 10;
  @override
  Widget build(BuildContext context) {
    RollModel model= Provider.of<RollModel>(context, listen: false);
    AIPainterModel provider = Provider.of<AIPainterModel>(context, listen: false);
    if(_countdownTimer!=null){
      _countdownTimer!.cancel();
    }
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(isActive&&provider.sdServiceAvailable){
        if(!model.backgroundProgress){
          post("$sdHttpService$GET_PROGRESS",
              formData: getPreview(id_live_preview), exceptionCallback: (e) {
                nextCheckTime = 10;
                countDown = 0;
              }).then((value) {
            if (null != value) {
              GenerateProgress progress = GenerateProgress.fromJson(value.data);
              forgroundProgressCheck(progress,model);
            }
          });
        }else{
          countDown ++;
          if(countDown==nextCheckTime){
            nextCheckTime == nextCheckTime*2;
            post("$sdHttpService$GET_PROGRESS",formData: getPreview(-1), exceptionCallback: (e) {
              nextCheckTime = 10;
              countDown = 0;
            }).then((value) {
              if (null != value) {
                GenerateProgress progress = GenerateProgress.fromJson(value.data);
                backgroundProgressCheck(progress,model);
              }
            });
          }
        }
      }

    });


    return Selector<RollModel, int>(
      selector: (_, model) => model.isGenerating,
      shouldRebuild: (pre, next) => pre != next,
      builder: (context, newValue, child) {
        return Stack(children: [
          child!,
          Selector<RollModel, Uint8List?>(
            builder: (_, newValue, child) => newValue == null
                ? Container()
                : Image.memory(newValue),
            selector: (_, model) => model.previewData,
            shouldRebuild: (pre, next) =>
            !(next == null && pre == null),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Offstage(
                offstage: newValue != 1,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ))
        ]);
      },
      child: FloatingActionButton(
        onPressed: widget.onPressed,
        child: Text(AppLocalizations.of(context).generate),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    isActive = state == AppLifecycleState.resumed;
  }

  void forgroundProgressCheck(GenerateProgress progress, RollModel model) {
    id_live_preview = progress.idLivePreview!;
    model.updateProgress(progress.progress);
    if (progress.livePreview != null) {
      model.updatePreviewData(base64Decode(
          progress.livePreview!.substring(BASE64_PREFIX.length)));
    }
    if (progress.completed == true) {
      logd("timer cancel");
      // _countdownTimer?.cancel();
      model.backgroundProgress = true;
    }
  }

  void backgroundProgressCheck(GenerateProgress progress, RollModel model) {
    if(null!=progress.completed&&!progress.completed!){
      // model.isBusy(REQUESTING);
      logt(TAG,'completed');
    }else{
      // model.updateNetworkState(INIT);
    }
  }
}