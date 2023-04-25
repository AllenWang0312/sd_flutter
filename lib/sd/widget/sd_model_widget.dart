import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean4json/SDModel.dart';
import 'package:sd/sd/pages/home_page.dart';
import 'package:sd/sd/roll/RollModel.dart';

import '../../common/ui_util.dart';
import '../AIPainterModel.dart';
import '../bean4json/PostPredictResult.dart';
import '../const/config.dart';
import '../http_service.dart';
import '../mocker.dart';

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
    // AIPainterModel provider =
    //     Provider.of<AIPainterModel>(context, listen: false);
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
                    child: Selector<AIPainterModel, String>(
                      selector: (context, model) => model.selectedSDModel,
                      shouldRebuild: (pre, next) =>
                          next != pre && next.isNotEmpty,
                      builder: (context, sdModel, child) {
                        RollModel roll =
                            Provider.of<RollModel>(context, listen: false);
                        return DropdownButton(
                            value: sdModel,
                            // hint: Text(selectedUpScale != null
                            //     ? "${selectedUpScale!.name}"
                            //     : "请选择模型"),
                            items: getNamesItems(models),
                            onChanged: (newValue) async {
                              roll.isBusy(REQUESTING);
                              post("$sdHttpService$RUN_PREDICT", formData: {
                                "data": [getModel(newValue)],
                                "fn_index": CMD_SWITCH_SD_MODEL
                              }, exceptionCallback: (e) {
                                roll.isBusy(ERROR);
                                Fluttertoast.showToast(
                                    msg: "模型切换失败",
                                    gravity: ToastGravity.CENTER);
                              }).then((value) {
                                if (null != value?.data) {
                                  RunPredictResult result =
                                      RunPredictResult.fromJson(value?.data);
                                  if (result.duration > 0) {
                                    roll.isBusy(INIT);
                                    Fluttertoast.showToast(
                                        msg: "模型切换成功",
                                        gravity: ToastGravity.CENTER);
                                    Provider.of<AIPainterModel>(context,
                                            listen: false)
                                        .updateSDModel(result.data[0].value!);
                                  } else {
                                    roll.isBusy(ERROR);
                                    Fluttertoast.showToast(
                                        msg: "模型切换失败",
                                        gravity: ToastGravity.CENTER);
                                  }
                                } else {
                                  roll.isBusy(ERROR);
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
              post("$sdHttpService$RUN_PREDICT", formData: refreshModel())
                  .then((value) {
                logt(TAG, value.toString());
              });
            },
            icon: Icon(Icons.refresh))
      ],
    );
  }
}
