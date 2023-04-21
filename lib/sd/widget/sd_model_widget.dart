import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/bean/PostPredictResult.dart';
import 'package:sd/sd/bean/SDModel.dart';
import 'package:sd/sd/model/RollModel.dart';
import 'package:sd/sd/pages/home_page.dart';

import '../../common/ui_util.dart';
import '../http_service.dart';
import '../config.dart';
import '../mocker.dart';
import '../model/AIPainterModel.dart';

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
    return FutureBuilder(
        future: get("$sdHttpService$GET_SD_MODELS"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List re = snapshot.data?.data as List;
            models = re.map((e) => SdModel.fromJson(e)).toList();
// logd(model.selectedSDModel);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Selector<AIPainterModel, String>(
                selector: (context, model) => model.selectedSDModel,
                shouldRebuild: (pre, next) => next != pre && next.isNotEmpty,
                builder: (context, sdModel, child) {
                  RollModel roll = Provider.of<RollModel>(context, listen: false);
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
                          "fn_index": CMD_SWITCH_MD_MODEL
                        }, exceptionCallback: (e) {
                          roll.isBusy(ERROR);
                          Fluttertoast.showToast(msg: "模型切换失败",gravity: ToastGravity.CENTER);
                        }).then((value) {
                          if (null != value?.data) {
                            RunPredictResult result =
                                RunPredictResult.fromJson(value?.data);
                            if (result.duration > 0) {
                              roll.isBusy(INIT);
                              Fluttertoast.showToast(msg: "模型切换成功",gravity: ToastGravity.CENTER);
                              Provider.of<AIPainterModel>(context, listen: false)
                                  .updateSDModel(result.data[0].value!);
                            } else {
                              roll.isBusy(ERROR);
                              Fluttertoast.showToast(msg: "模型切换失败",gravity: ToastGravity.CENTER);
                            }
                          } else {
                            roll.isBusy(ERROR);
                            Fluttertoast.showToast(msg: "模型切换失败",gravity: ToastGravity.CENTER);
                          }
                        });
                      });
                },
              ),
            );
          } else {
            return const Placeholder(
              fallbackWidth: 100,
              fallbackHeight: 48,
            );
          }
        });
  }
}
