

import 'package:flutter/material.dart';
import 'package:sd/sd/widget/restartable_widget.dart';

const SHAPE_IMAGE_CARD = RoundedRectangleBorder(
    borderRadius:
    BorderRadius.all(Radius.circular(12.0)));

bottomSheetItem(String title, Function()? callback) {
  return Expanded(
    child: InkWell(
      onTap: callback,
      child: Center(
        child: Text(title),
      ),
    ),
  );
}


void showRestartDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text("立即重启"),
                content: Text("关键配置已变更,点击确定立即重启"),
                actions: [
                    TextButton(
                        onPressed: () async {
                            RestartableWidget.restartApp(context);
                        },
                        child: Text("确定"))
                ],
            );
        });
}