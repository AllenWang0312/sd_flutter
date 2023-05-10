import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean4json/SDModel.dart';

import '../../../../common/ui_util.dart';
import '../../../provider/AIPainterModel.dart';
import '../../../bean4json/PostPredictResult.dart';
import '../../../const/config.dart';
import '../../../http_service.dart';
import '../../../mocker.dart';
import '../txt2img/TXT2IMGModel.dart';

const TAG = "SDModelWidget";

class SDModelWidget extends StatelessWidget {
  String getModel(String name) {
    List<SdModel> ms =
        models.where((element) => element.modelName == name).toList();
    if (ms.length == 1) {
      return ms[0].title;
    }
    return '';
  }

  late List<SdModel> models;

  @override
  Widget build(BuildContext context) {
    AIPainterModel provider =
        Provider.of<AIPainterModel>(context, listen: false);
    return Row(
      children: [
        Expanded(
          child: FutureBuilder(
              future: get("$sdHttpService$GET_SD_MODELS"),
              // future: post("$sdHttpService$RUN_PREDICT",
              //     formData: refreshModel()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List re = snapshot.data?.data as List;
                  models = re.map((e) => SdModel.fromJson(e)).toList();
                  // logt(TAG,snapshot.data?.data);
                  //
                  // List re = snapshot.data?.data['data'][0]['choices'] as List;
                  // models = re.map((e) => SdModel.fromString(e.toString())).toList();

// logd(model.selectedSDModel);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Selector<AIPainterModel, String?>(
                      selector: (context, model) => model.selectedSDModel,
                      shouldRebuild: (pre,next){
                        return models.contains(next); //todo 总是说没有项目 过滤一下
                      },
                      builder: (context, sdModel, child) {
                        TXT2IMGModel roll =
                            Provider.of<TXT2IMGModel>(context, listen: false);
                        return DropdownButton(
                            value: sdModel,
                            // hint: Text(selectedUpScale != null
                            //     ? "${selectedUpScale!.name}"
                            //     : "请选择模型"),
                            items: getNamesItems(models),
                            onChanged: (newValue) async {
                              post("$sdHttpService$RUN_PREDICT", formData: {
                                "data": [newValue],//getModel
                                "fn_index": cmd.switchSDModel
                              },provider: provider, exceptionCallback: (e) {
                                Provider.of<AIPainterModel>(context,
                                    listen: false)
                                    .updateSDModel(null);
                                Fluttertoast.showToast(
                                    msg: "模型切换失败",
                                    gravity: ToastGravity.CENTER);
                              }).then((value) {
                                if (null != value?.data) {
                                  RunPredictResult result =
                                      RunPredictResult.fromJson(value?.data);
                                  if (result.duration > 0) {
                                    Fluttertoast.showToast(
                                        msg: "模型切换成功",
                                        gravity: ToastGravity.CENTER);
                                    Provider.of<AIPainterModel>(context,
                                            listen: false)
                                        .updateSDModel(result.data[0].value!);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "模型切换失败",
                                        gravity: ToastGravity.CENTER);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "模型切换失败",
                                      gravity: ToastGravity.CENTER);
                                }
                              });
                            });
                      },
                    ),
                  );
                } else {
                  return myPlaceholder(100, 48);
                }
              }),
        ),
        IconButton(
            onPressed: () {
              post("$sdHttpService$RUN_PREDICT", formData: {
                "fn_index": cmd.refreshModel,
                "data": [],
                // "session_hash": "xo1qqnyjm6"
              })
                  .then((value) {
                logt(TAG, value.toString());
              });
            },
            icon: Icon(Icons.refresh))
      ],
    );
  }
}
